defmodule CsgoStats.Matches.Match do
  alias CsgoStats.Events

  defstruct [
    :server_instance_token,
    :phase,
    :wins,
    :map,
    :players,
    :round_timeout,
    :bomb_timeout,
    :kill_feed,
    :score_terrorist,
    :score_ct
  ]

  defmodule Player do
    defstruct team: nil, health: 100, armor: 0, kills: 0, assists: 0, deaths: 0, money: 800
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

  def apply(%{phase: phase} = state, %Events.GameCommencing{})
      when phase in [:pre_game, :game_over] do
    %{state | phase: :game_commencing}
  end

  def apply(%{phase: :game_commencing} = state, %Events.MatchStart{} = event) do
    %{state | phase: :freeze_period, map: event.map}
  end

  def apply(%{phase: :freeze_period} = state, %Events.RoundStart{}) do
    # TODO: set timeout depending on cvar mp_roundtime or mp_roundtime_defuse
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 3 * 60, :second)
    %{state | phase: :round, round_timeout: timeout}
  end

  def apply(state, %Events.TeamWon{} = event) do
    %{
      state
      | wins: state.wins ++ [event.win_condition],
        score_terrorist: event.terrorist_score,
        score_ct: event.ct_score
    }
  end

  def apply(%{phase: :round} = state, %Events.RoundEnd{}) do
    %{state | phase: :round_over, round_timeout: nil, bomb_timeout: nil}
  end

  def apply(%{phase: :round_over} = state, %Events.GameOver{}) do
    %{state | phase: :game_over}
  end

  def apply(%{phase: :round_over} = state, %Events.FreezePeriodStarted{}) do
    players =
      Map.new(state.players, fn {username, player} ->
        {username, %{player | health: 100}}
      end)

    %{state | phase: :freeze_period, players: players, kill_feed: []}
  end

  def apply(state, %Events.PlayerSwitchedTeam{} = event) do
    players =
      Map.update(state.players, event.player.username, %Player{team: event.to}, fn player ->
        %{player | team: event.to}
      end)

    %{state | players: players}
  end

  def apply(state, %Events.PlantedTheBomb{}) do
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), 40, :second)
    %{state | bomb_timeout: timeout}
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
        %{player | deaths: player.deaths + 1, armor: 0}
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
        %{player | deaths: player.deaths + 1}
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

  def apply(state, _event) do
    state
  end
end
