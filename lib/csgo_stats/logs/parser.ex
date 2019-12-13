defmodule CsgoStats.Logs.Parser do
  @moduledoc """
  Parses CS:GO game server log lines to events
  """

  import NimbleParsec

  alias CsgoStats.Events

  @doc """
  Parse a log line into a corresponding event.

  ## Examples

      iex> CsgoStats.Logs.Parser.parse(~s/World triggered "Game_Commencing"/)
      {:ok, %CsgoStats.Events.GameCommencing{}}
  """
  def parse(line) do
    case do_parse(line) do
      {:ok, [event], "", _, _, _} -> {:ok, event}
      {:ok, [event], leftovers, _, _, _} -> {:ok, event, leftovers}
      {:error, error, unparsed, _context, _, _} -> {:error, error, unparsed}
    end
  end

  ### World events
  # World triggered "Game_Commencing"
  game_commencing =
    ignore(string(~s/World triggered "Game_Commencing"/))
    |> reduce({:game_commencing, []})

  defp game_commencing([]) do
    %Events.GameCommencing{}
  end

  # World triggered "Match_Start" on "de_inferno"
  match_start =
    ignore(string(~s/World triggered "Match_Start" on "/))
    |> ascii_string([?a..?z, ?_], min: 1)
    |> ignore(string(~s/"/))
    |> reduce({:match_start, []})

  defp match_start([map]) do
    %Events.MatchStart{map: map}
  end

  # World triggered "Round_Start"
  round_start =
    ignore(string(~s/World triggered "Round_Start"/))
    |> reduce({:round_start, []})

  defp round_start([]) do
    %Events.RoundStart{}
  end

  # World triggered "Round_End"
  round_end =
    ignore(string(~s/World triggered "Round_End"/))
    |> reduce({:round_end, []})

  defp round_end([]) do
    %Events.RoundEnd{}
  end

  # Starting Freeze period
  freeze_period_started =
    ignore(string("Starting Freeze period"))
    |> reduce({:freeze_period_started, []})

  defp freeze_period_started([]) do
    %Events.FreezePeriodStarted{}
  end

  team =
    choice([string("CT"), string("TERRORIST"), string("T"), string("Unassigned")])
    |> reduce({:team, []})

  defp team([team]) do
    case team do
      "CT" -> :ct
      "TERRORIST" -> :terrorist
      "T" -> :terrorist
      "Unassigned" -> nil
    end
  end

  win_condition =
    ignore(string("SFUI_Notice_"))
    |> choice([
      string("Terrorists_Win"),
      string("Target_Bombed"),
      string("Bomb_Defused"),
      string("Target_Saved"),
      string("CTs_Win")
    ])
    |> reduce({:win_condition, []})

  defp win_condition([condition]) do
    case condition do
      "Terrorists_Win" -> :terrorists_win
      "CTs_Win" -> :cts_win
      "Target_Bombed" -> :target_bombed
      "Bomb_Defused" -> :bomb_defused
      "Target_Saved" -> :target_saved
    end
  end

  team_score =
    ignore(string("("))
    |> concat(team)
    |> ignore(string(~s/ "/))
    |> integer(min: 1)
    |> ignore(string(~s/")/))

  # Team "TERRORIST" triggered "SFUI_Notice_Terrorists_Win" (CT "0") (T "1")
  team_won =
    ignore(string(~s/Team "/))
    |> concat(team)
    |> ignore(string(~s/" triggered "/))
    |> concat(win_condition)
    |> ignore(string(~s/" /))
    |> concat(team_score)
    |> ignore(string(" "))
    |> concat(team_score)
    |> reduce({:team_won, []})

  defp team_won([team, win_condition, :ct, ct_score, :terrorist, terrorist_score]) do
    %Events.TeamWon{
      team: team,
      win_condition: win_condition,
      ct_score: ct_score,
      terrorist_score: terrorist_score
    }
  end

  game_mode = string("casual")
  game_map = string("de_inferno")

  # Game Over: casual mg_de_inferno de_inferno score 3:8 after 18 min
  game_over =
    ignore(string("Game Over: "))
    |> concat(game_mode)
    |> ignore(string(" "))
    |> ignore(ascii_string([?a..?z, ?_], min: 1))
    |> ignore(string(" "))
    |> concat(game_map)
    |> ignore(string(" score "))
    |> integer(min: 1)
    |> ignore(string(":"))
    |> integer(min: 1)
    |> ignore(string(" after "))
    |> integer(min: 1)
    |> ignore(string(" min"))
    |> reduce({:game_over, []})

  defp game_over([game_mode, game_map, ct_score, t_score, duration]) do
    %Events.GameOver{
      game_mode: game_mode,
      game_map: game_map,
      ct_score: ct_score,
      t_score: t_score,
      duration: duration
    }
  end

  ### Player events

  username = utf8_string([{:not, ?<}], min: 1)

  user_tag =
    ignore(string("<"))
    |> integer(min: 1)
    |> ignore(string(">"))

  steam_id =
    ignore(string("<"))
    |> choice([string("BOT"), utf8_string([{:not, ?>}], min: 1)])
    |> ignore(string(">"))

  team_angle =
    ignore(string("<"))
    |> concat(optional(team))
    |> ignore(string(">"))

  player =
    ignore(string(~s/"/))
    |> concat(username)
    |> concat(user_tag)
    |> concat(steam_id)
    |> concat(optional(team_angle))
    |> ignore(string(~s/"/))
    |> reduce({:player, []})

  defp player([username, _tag, steam_id]) do
    %{username: username, steam_id: steam_id, team: nil}
  end

  defp player([username, _tag, steam_id, team]) do
    %{username: username, steam_id: steam_id, team: team}
  end

  # "Uri<13><BOT><>" connected, address ""
  player_connected =
    player
    |> ignore(string(~s/ connected, address "/))
    |> optional(utf8_string([{:not, ?"}], min: 1))
    |> ignore(string(~s/"/))
    |> reduce({:player_connected, []})

  defp player_connected([player]) do
    %Events.PlayerConnected{player: player}
  end

  defp player_connected([player, address]) do
    %Events.PlayerConnected{player: player, address: address}
  end

  # "Uri<13><BOT>" switched from team <Unassigned> to <CT>
  player_switched_team =
    player
    |> ignore(string(" switched from team "))
    |> concat(team_angle)
    |> ignore(string(" to "))
    |> concat(team_angle)
    |> reduce({:player_switched_team, []})

  defp player_switched_team([player, from, to]) do
    %Events.PlayerSwitchedTeam{player: player, from: from, to: to}
  end

  # "Uri<13><BOT><>" entered the game
  player_entered_the_game =
    player
    |> ignore(string(" entered the game"))
    |> reduce({:player_entered_the_game, []})

  defp player_entered_the_game([player]) do
    %Events.PlayerEnteredTheGame{player: player}
  end

  # "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" triggered "Got_The_Bomb"
  got_the_bomb =
    player
    |> ignore(string(~s/ triggered "Got_The_Bomb"/))
    |> reduce({:got_the_bomb, []})

  defp got_the_bomb([player]) do
    %Events.GotTheBomb{player: player}
  end

  # "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" triggered "Dropped_The_Bomb"
  dropped_the_bomb =
    player
    |> ignore(string(~s/ triggered "Dropped_The_Bomb"/))
    |> reduce({:dropped_the_bomb, []})

  defp dropped_the_bomb([player]) do
    %Events.DroppedTheBomb{player: player}
  end

  # "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" triggered "Planted_The_Bomb"
  planted_the_bomb =
    player
    |> ignore(string(~s/ triggered "Planted_The_Bomb"/))
    |> reduce({:planted_the_bomb, []})

  defp planted_the_bomb([player]) do
    %Events.PlantedTheBomb{player: player}
  end

  # "Clarence<17><BOT><CT>" triggered "Begin_Bomb_Defuse_With_Kit"
  began_bomb_defuse =
    player
    |> ignore(string(~s/ triggered "/))
    |> string("Begin_Bomb_Defuse_With_Kit")
    |> ignore(string(~s/"/))
    |> reduce({:began_bomb_defuse, []})

  defp began_bomb_defuse([player, "Begin_Bomb_Defuse_With_Kit"]) do
    %Events.BeganBombDefuse{player: player, kit: true}
  end

  # "Elmer<18><BOT><CT>" triggered "Defused_The_Bomb"
  defused_the_bomb =
    player
    |> ignore(string(~s/ triggered "Defused_The_Bomb"/))
    |> reduce({:defused_the_bomb, []})

  defp defused_the_bomb([player]) do
    %Events.DefusedTheBomb{player: player}
  end

  position =
    ignore(string("["))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string(" "))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string(" "))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string("]"))

  weapon =
    ignore(string(~s/"/))
    |> ascii_string([?a..?z, ?0..?9], min: 1)
    |> ignore(string(~s/"/))

  stat =
    ignore(
      choice([
        string(~s/(damage_armor "/),
        string(~s/(damage "/),
        string(~s/(health "/),
        string(~s/(armor "/)
      ])
    )
    |> integer(min: 1)
    |> ignore(string(~s/")/))

  hitgroup =
    ignore(string(~s/(hitgroup "/))
    |> ascii_string([?a..?z, ?\s], min: 1)
    |> ignore(string(~s/")/))

  # "Niles<16><BOT><TERRORIST>" [123 616 72] attacked "Elmer<18><BOT><CT>" [932 550 88] with "glock" (damage "17") (damage_armor "0") (health "83") (armor "100") (hitgroup "right leg")
  attacked =
    player
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" attacked "))
    |> concat(player)
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" with "))
    |> concat(weapon)
    |> ignore(string(" "))
    |> concat(stat)
    |> ignore(string(" "))
    |> concat(stat)
    |> ignore(string(" "))
    |> concat(stat)
    |> ignore(string(" "))
    |> concat(stat)
    |> ignore(string(" "))
    |> concat(hitgroup)
    |> reduce({:attacked, []})

  defp attacked([
         attacker,
         attacked,
         weapon,
         damage,
         damage_armor,
         health,
         armor,
         hitgroup
       ]) do
    %Events.Attacked{
      attacked: attacked,
      attacker: attacker,
      weapon: weapon,
      damage: damage,
      damage_armor: damage_armor,
      health: health,
      armor: armor,
      hitgroup: hitgroup
    }
  end

  # "Niles<16><BOT><TERRORIST>" [418 570 87] killed "Elmer<18><BOT><CT>" [944 538 152] with "glock"
  killed =
    player
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" killed "))
    |> concat(player)
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" with "))
    |> concat(weapon)
    |> optional(choice([string(" (headshot)"), string(" (penetrated)")]))
    |> reduce({:killed, []})

  defp killed([killer, killed, weapon]) do
    %Events.Killed{
      killer: killer,
      killed: killed,
      weapon: weapon,
      headshot: false,
      penetrated: false
    }
  end

  defp killed([killer, killed, weapon, " (headshot)"]) do
    %Events.Killed{
      killer: killer,
      killed: killed,
      weapon: weapon,
      headshot: true,
      penetrated: false
    }
  end

  defp killed([killer, killed, weapon, " (penetrated)"]) do
    %Events.Killed{
      killer: killer,
      killed: killed,
      weapon: weapon,
      headshot: false,
      penetrated: true
    }
  end

  # "Elmer<18><BOT><CT>" assisted killing "Niles<16><BOT><TERRORIST>"
  assisted =
    player
    |> ignore(string(" assisted killing "))
    |> concat(player)
    |> reduce({:assisted, []})

  defp assisted([assistant, killed]) do
    %Events.Assisted{
      assistant: assistant,
      killed: killed
    }
  end

  # "Graham<14><BOT><TERRORIST>" [1494 792 204] was killed by the bomb.
  killed_by_the_bomb =
    player
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" was killed by the bomb."))
    |> reduce({:killed_by_the_bomb, []})

  defp killed_by_the_bomb([player]) do
    %Events.KilledByTheBomb{player: player}
  end

  # "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" [849 2387 143] killed other "chicken<159>" [814 2555 138] with "awp"
  killed_other =
    player
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(~s/ killed other "/))
    |> choice([string("chicken"), string("func_breakable")])
    |> ignore(ascii_string([?0..?9, ?<, ?>, ?"], min: 1))
    |> ignore(string(" "))
    |> ignore(position)
    |> ignore(string(" with "))
    |> concat(weapon)
    |> optional(choice([string(" (headshot)"), string(" (penetrated)")]))
    |> reduce({:killed_other, []})

  defp killed_other([killer, killed, weapon]) do
    %Events.KilledOther{
      killer: killer,
      killed: killed,
      weapon: weapon,
      headshot: false,
      penetrated: false
    }
  end

  defp killed_other([killer, killed, weapon, " (headshot)"]) do
    %Events.KilledOther{
      killer: killer,
      killed: killed,
      weapon: weapon,
      penetrated: false,
      headshot: true
    }
  end

  defp killed_other([killer, killed, weapon, " (penetrated)"]) do
    %Events.KilledOther{
      killer: killer,
      killed: killed,
      weapon: weapon,
      penetrated: true,
      headshot: false
    }
  end

  award =
    choice([
      string("3k"),
      string("hsp"),
      string("firstkills"),
      string("cashspent"),
      string("deaths"),
      string("mvps"),
      string("assists")
    ])

  # ACCOLADE, FINAL: {3k},	Neil<8>,	VALUE: 1.000000,	POS: 2,	SCORE: 20.000002
  accolade =
    ignore(string("ACCOLADE, FINAL: {"))
    |> concat(award)
    |> ignore(string("},\t"))
    |> concat(username)
    |> concat(user_tag)
    |> ignore(string(",\tVALUE: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(",\tPOS: "))
    |> integer(min: 1)
    |> ignore(string(",\tSCORE: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> reduce({:accolade, []})

  defp accolade([award, player, _tag, value, position, score]) do
    %Events.Accolade{
      award: award,
      player: %{username: player},
      value: String.to_float(value),
      position: position,
      score: String.to_float(score)
    }
  end

  # "tbroedsgaard<12><STEAM_1:1:42376214><Unassigned>" disconnected (reason "Disconnect")
  player_disconnected =
    player
    |> ignore(string(~s/ disconnected (reason "/))
    |> choice([string("Disconnect"), string("Kicked by Console")])
    |> ignore(string(~s/")/))
    |> reduce({:player_disconnected, []})

  defp player_disconnected([player, reason]) do
    %Events.PlayerDisconnected{player: player, reason: reason}
  end

  game_event =
    choice([
      game_commencing,
      freeze_period_started,
      match_start,
      round_start,
      team_won,
      round_end,
      game_over
    ])

  player_event =
    choice([
      player_connected,
      player_switched_team,
      player_entered_the_game,
      got_the_bomb,
      dropped_the_bomb,
      planted_the_bomb,
      began_bomb_defuse,
      defused_the_bomb,
      attacked,
      killed,
      assisted,
      killed_by_the_bomb,
      killed_other,
      accolade,
      player_disconnected
    ])

  defparsecp(
    :do_parse,
    choice([game_event, player_event])
  )
end
