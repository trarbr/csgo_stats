defmodule CsgoStats.Matches.Match do
  alias CsgoStats.Events

  defstruct [
    :server_instance_token,
    :phase,
    :wins,
    :map,
    :players,
    :timeout,
    :time_left,
    :kill_feed,
    :score_terrorist,
    :score_ct
  ]

  defmodule Player do
    defstruct team: nil,
              health: 100,
              armor: 0,
              kills: 0,
              assists: 0,
              deaths: 0,
              money: 800,
              c4: false,
              defuser: false,
              helmet: false,
              weapons: []

    def add_item(player, item) do
      case item do
        :c4 -> %{player | c4: true}
        :defuser -> %{player | defuser: true}
        :vesthelm -> %{player | armor: 100, helmet: true}
        :vest -> %{player | armor: 100}
        :knife -> player
        :knife_t -> player
        weapon -> %{player | weapons: player.weapons ++ [weapon]}
      end
    end

    def remove_item(player, item) do
      case item do
        :c4 -> %{player | c4: false}
        :defuser -> %{player | defuser: false}
        :vesthelm -> %{player | armor: 0, helmet: false}
        :vest -> %{player | armor: 0}
        weapon -> %{player | weapons: player.weapons -- [weapon]}
      end
    end
  end

  def new(server_instance_token) do
    %__MODULE__{
      server_instance_token: server_instance_token,
      phase: :pre_game,
      score_terrorist: 0,
      score_ct: 0,
      wins: [],
      players: %{},
      kill_feed: []
    }
  end

  def apply(state, event)

  def apply(state, %Events.GameCommencing{}) do
    %{state | phase: :game_commencing}
  end

  def apply(state, %Events.MatchStart{} = event) do
    # TODO: set timeout depending on cvar mp_freezetime
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :second)

    %{state | phase: :freeze_period, map: event.map, timeout: timeout}
    |> update_time_left()
  end

  def apply(state, %Events.FreezePeriodStarted{}) do
    players =
      Map.new(state.players, fn {username, player} ->
        {username, %{player | health: 100}}
      end)

    # TODO: set timeout depending on cvar mp_freezetime
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :second)

    %{
      state
      | phase: :freeze_period,
        players: players,
        kill_feed: [],
        timeout: timeout
    }
    |> update_time_left()
  end

  def apply(state, %Events.RoundStart{}) do
    # TODO: set timeout depending on cvar mp_roundtime or mp_roundtime_defuse
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 90, :second)

    %{state | phase: :round_started, timeout: timeout}
    |> update_time_left()
  end

  def apply(state, %Events.PlantedTheBomb{}) do
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 40, :second)

    %{state | phase: :bomb_planted, timeout: timeout}
    |> update_time_left()
  end

  def apply(state, %Events.TeamWon{} = event) do
    %{
      state
      | wins: state.wins ++ [event.win_condition],
        score_terrorist: event.terrorist_score,
        score_ct: event.ct_score,
        phase: {:round_over, event.win_condition},
        timeout: nil,
        time_left: nil
    }
  end

  def apply(state, %Events.GameOver{}) do
    %{state | phase: :game_over, timeout: nil, time_left: nil}
  end

  def apply(state, %Events.PlayerSwitchedTeam{} = event) do
    players =
      Map.update(state.players, event.player.username, %Player{team: event.to}, fn player ->
        %{player | team: event.to}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.Attacked{} = event) do
    players =
      Map.update!(state.players, event.attacked.username, fn player ->
        %{player | health: event.health, armor: event.armor}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.Killed{} = event) do
    players =
      Map.update!(state.players, event.killed.username, fn player ->
        %{player | deaths: player.deaths + 1, armor: 0, weapons: []}
      end)

    players =
      Map.update!(players, event.killer.username, fn player ->
        %{player | kills: player.kills + 1}
      end)

    %{state | players: players, kill_feed: [event | state.kill_feed]}
  end

  def apply(state, %Events.Assisted{} = event) do
    players =
      Map.update!(state.players, event.assistant.username, fn player ->
        %{player | assists: player.assists + 1}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.KilledByTheBomb{} = event) do
    players =
      Map.update!(state.players, event.player.username, fn player ->
        %{player | deaths: player.deaths + 1, weapons: []}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.MoneyChange{} = event) do
    players =
      Map.update!(state.players, event.player.username, fn player ->
        %{player | money: event.result}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.PickedUp{} = event) do
    players =
      Map.update!(state.players, event.player.username, fn player ->
        Player.add_item(player, event.item)
      end)

    %{state | players: players}
  end

  def apply(state, %Events.Dropped{} = event) do
    players =
      Map.update!(state.players, event.player.username, fn player ->
        Player.remove_item(player, event.item)
      end)

    %{state | players: players}
  end

  def apply(%{timeout: timeout} = state, :tick) when timeout !== nil do
    update_time_left(state)
  end

  def apply(state, _event) do
    state
  end

  defp update_time_left(state) do
    time_left =
      state.timeout
      |> NaiveDateTime.diff(NaiveDateTime.utc_now())
      |> max(0)

    %{state | time_left: time_left}
  end
end
