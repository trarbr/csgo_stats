defmodule CsgoStats.Logs.ParserTest do
  use ExUnit.Case, async: true

  doctest CsgoStats.Logs.Parser

  alias CsgoStats.Logs.Parser
  alias CsgoStats.Events

  describe "Events" do
    test "Unhandled event" do
      line = "11/24/2019 - 21:43:02.156 - \"coop\" = \"0\""
      assert {:ok, []} = Parser.parse(line)
    end

    test "Game commencing" do
      line = "11/24/2019 - 21:43:39.781 - World triggered \"Game_Commencing\""
      assert {:ok, [%Events.GameCommencing{timestamp: ts}]} = Parser.parse(line)
      assert NaiveDateTime.compare(ts, ~N[2019-11-24 21:43:39.781]) == :eq
    end

    test "Match start" do
      line = "11/24/2019 - 21:43:39.781 - World triggered \"Match_Start\" on \"de_inferno\""
      assert {:ok, [%Events.MatchStart{game_map: :de_inferno}]} = Parser.parse(line)
    end

    test "Round start" do
      line = "11/24/2019 - 21:43:39.781 - World triggered \"Round_Start\""
      assert {:ok, [%Events.RoundStart{}]} = Parser.parse(line)
    end

    test "Round end" do
      line = "11/24/2019 - 21:43:39.781 - World triggered \"Round_End\""
      assert {:ok, [%Events.RoundEnd{}]} = Parser.parse(line)
    end

    test "Starting freeze period" do
      line = "11/24/2019 - 21:43:39.781 - Starting Freeze period"
      assert {:ok, [%Events.FreezePeriodStarted{}]} = Parser.parse(line)
    end

    test "Team won" do
      line =
        "11/24/2019 - 21:43:39.781 - Team \"TERRORIST\" triggered \"SFUI_Notice_Terrorists_Win\" (CT \"0\") (T \"1\")"

      assert {:ok,
              [
                %Events.TeamWon{
                  team: :terrorist,
                  win_condition: :terrorists_win,
                  ct_score: 0,
                  terrorist_score: 1
                }
              ]} = Parser.parse(line)
    end

    test "Game over" do
      line =
        "11/24/2019 - 21:43:39.781 - Game Over: casual mg_de_inferno de_inferno score 3:8 after 18 min"

      assert {:ok,
              [
                %Events.GameOver{
                  game_mode: :casual,
                  game_map: :de_inferno,
                  ct_score: 3,
                  t_score: 8,
                  duration: 18
                }
              ]} = Parser.parse(line)
    end

    test "Player connected" do
      line = "11/24/2019 - 21:43:39.781 - \"Uri<13><BOT><>\" connected, address \"\""

      assert {:ok, [%Events.PlayerConnected{address: nil, player: %{username: "Uri"}}]} =
               Parser.parse(line)
    end

    test "Player switched team" do
      line =
        "11/24/2019 - 21:43:39.781 - \"Uri<13><BOT>\" switched from team <Unassigned> to <CT>"

      assert {:ok,
              [%Events.PlayerSwitchedTeam{player: %{username: "Uri"}, from: :unassigned, to: :ct}]} =
               Parser.parse(line)
    end

    test "Player entered the game" do
      line = "11/24/2019 - 21:43:39.781 - \"Uri<13><BOT><>\" entered the game"

      assert {:ok, [%Events.PlayerEnteredTheGame{player: %{username: "Uri"}}]} =
               Parser.parse(line)
    end

    test "Got the bomb" do
      line =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" triggered \"Got_The_Bomb\""

      assert {:ok, [%Events.GotTheBomb{player: %{username: "tbroedsgaard"}}]} = Parser.parse(line)
    end

    test "Dropped the bomb" do
      line =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" triggered \"Dropped_The_Bomb\""

      assert {:ok, [%Events.DroppedTheBomb{player: %{username: "tbroedsgaard"}}]} =
               Parser.parse(line)
    end

    test "Planted the bomb" do
      line =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" triggered \"Planted_The_Bomb\""

      assert {:ok, [%Events.PlantedTheBomb{player: %{username: "tbroedsgaard"}}]} =
               Parser.parse(line)
    end

    test "Began bomb defuse with kit" do
      line =
        "11/24/2019 - 21:43:39.781 - \"Clarence<17><BOT><CT>\" triggered \"Begin_Bomb_Defuse_With_Kit\""

      assert {:ok, [%Events.BeganBombDefuse{player: %{username: "Clarence"}, kit: true}]} =
               Parser.parse(line)
    end

    test "Defused the bomb" do
      line = "11/24/2019 - 21:43:39.781 - \"Elmer<18><BOT><CT>\" triggered \"Defused_The_Bomb\""

      assert {:ok, [%Events.DefusedTheBomb{player: %{username: "Elmer"}}]} = Parser.parse(line)
    end

    test "Attacked" do
      line =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><CT>\" [932 -550 88] attacked \"Niles<16><BOT><TERRORIST>\" [145 648 77] with \"hkp2000\" (damage \"61\") (damage_armor \"29\") (health \"39\") (armor \"70\") (hitgroup \"head\")"

      assert {:ok,
              [
                %Events.Attacked{
                  attacker: %{
                    username: "tbroedsgaard",
                    steam_id: "STEAM_1:1:42376214",
                    team: :ct
                  },
                  attacked: %{
                    username: "Niles",
                    steam_id: "BOT",
                    team: :terrorist
                  },
                  weapon: :hkp2000,
                  damage: 61,
                  damage_armor: 29,
                  health: 39,
                  armor: 70,
                  hitgroup: :head
                }
              ]} = Parser.parse(line)

      left_leg =
        "11/24/2019 - 21:43:39.781 - \"Clarence<17><BOT><CT>\" [1936 -184 256] attacked \"Niles<16><BOT><TERRORIST>\" [1798 -366 256] with \"aug\" (damage \"12\") (damage_armor \"0\") (health \"88\") (armor \"100\") (hitgroup \"left leg\")"

      assert {:ok,
              [
                %Events.Attacked{
                  attacker: %{username: "Clarence"},
                  attacked: %{username: "Niles"},
                  weapon: :aug,
                  hitgroup: :left_leg
                }
              ]} = Parser.parse(left_leg)
    end

    test "Killed" do
      line =
        "11/24/2019 - 21:43:39.781 - \"Niles<16><BOT><TERRORIST>\" [418 570 87] killed \"Elmer<18><BOT><CT>\" [944 538 152] with \"glock\""

      assert {:ok,
              [
                %Events.Killed{
                  killer: %{username: "Niles"},
                  killed: %{username: "Elmer"},
                  weapon: :glock,
                  headshot: false,
                  penetrated: false
                }
              ]} = Parser.parse(line)

      knifed =
        "11/24/2019 - 21:43:39.781 - \"Niles<16><BOT><TERRORIST>\" [632 585 91] killed \"Albert<23><BOT><CT>\" [600 555 154] with \"knife_t\""

      assert {:ok,
              [
                %Events.Killed{
                  killer: %{username: "Niles"},
                  killed: %{username: "Albert"},
                  weapon: :knife_t,
                  headshot: false,
                  penetrated: false
                }
              ]} = Parser.parse(knifed)

      silencer =
        "11/24/2019 - 21:43:39.781 - \"Niles<16><BOT><TERRORIST>\" [632 585 91] killed \"Albert<23><BOT><CT>\" [600 555 154] with \"usp_silencer\""

      assert {:ok,
              [
                %Events.Killed{
                  killer: %{username: "Niles"},
                  killed: %{username: "Albert"},
                  weapon: :usp_silencer,
                  headshot: false,
                  penetrated: false
                }
              ]} = Parser.parse(silencer)

      headshot =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" [1873 314 160] killed \"Yanni<15><BOT><CT>\" [1841 283 206] with \"glock\" (headshot)"

      assert {:ok,
              [
                %Events.Killed{
                  killer: %{username: "tbroedsgaard"},
                  killed: %{username: "Yanni"},
                  weapon: :glock,
                  headshot: true,
                  penetrated: false
                }
              ]} = Parser.parse(headshot)

      penetrated =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" [2150 407 160] killed \"Clarence<17><BOT><CT>\" [1879 628 224] with \"glock\" (penetrated)"

      assert {:ok,
              [
                %Events.Killed{
                  killer: %{username: "tbroedsgaard"},
                  killed: %{username: "Clarence"},
                  weapon: :glock,
                  headshot: false,
                  penetrated: true
                }
              ]} = Parser.parse(penetrated)
    end

    test "Killed by the bomb" do
      line =
        "11/24/2019 - 21:43:39.781 - \"Graham<14><BOT><TERRORIST>\" [1494 792 204] was killed by the bomb."

      assert {:ok, [%Events.KilledByTheBomb{player: %{username: "Graham"}}]} = Parser.parse(line)
    end

    test "Killed other" do
      chicken =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" [849 2387 143] killed other \"chicken<159>\" [814 2555 138] with \"awp\""

      assert {:ok,
              [
                %Events.KilledOther{
                  killer: %{username: "tbroedsgaard"},
                  killed: :chicken,
                  weapon: :awp,
                  penetrated: false,
                  headshot: false
                }
              ]} = Parser.parse(chicken)

      chicken =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>\" [849 2387 143] killed other \"chicken<159>\" [814 2555 138] with \"awp\" (headshot)"

      assert {:ok,
              [
                %Events.KilledOther{
                  killer: %{username: "tbroedsgaard"},
                  killed: :chicken,
                  weapon: :awp,
                  penetrated: false,
                  headshot: true
                }
              ]} = Parser.parse(chicken)

      func_breakable =
        "11/24/2019 - 21:43:39.781 - \"Yogi<49><BOT><CT>\" [-471 -139 6] killed other \"func_breakable<113>\" [973 -61 175] with \"mp7\" (penetrated)"

      assert {:ok,
              [
                %Events.KilledOther{
                  killer: %{username: "Yogi"},
                  killed: :func_breakable,
                  weapon: :mp7,
                  penetrated: true,
                  headshot: false
                }
              ]} = Parser.parse(func_breakable)
    end

    test "Assisted" do
      line =
        "11/24/2019 - 21:43:39.781 - \"Elmer<18><BOT><CT>\" assisted killing \"Niles<16><BOT><TERRORIST>\""

      assert {:ok,
              [%Events.Assisted{assistant: %{username: "Elmer"}, killed: %{username: "Niles"}}]} =
               Parser.parse(line)
    end

    test "Accolade" do
      line =
        "11/24/2019 - 21:43:39.781 - ACCOLADE, FINAL: {3k},	Neil<8>,	VALUE: 1.000000,	POS: 2,	SCORE: 20.000002"

      assert {:ok,
              [
                %Events.Accolade{
                  player: %{username: "Neil"},
                  award: :"3k",
                  value: 1.0,
                  score: 20.000002
                }
              ]} = Parser.parse(line)
    end

    test "Player disconnected" do
      line =
        "11/24/2019 - 21:43:39.781 - \"tbroedsgaard<12><STEAM_1:1:42376214><Unassigned>\" disconnected (reason \"Disconnect\")"

      assert {:ok,
              [
                %Events.PlayerDisconnected{
                  player: %{username: "tbroedsgaard"},
                  reason: :disconnect
                }
              ]} = Parser.parse(line)

      kicked_by_console =
        "11/24/2019 - 21:43:39.781 - \"Fergus<20><BOT><TERRORIST>\" disconnected (reason \"Kicked by Console\")"

      assert {:ok,
              [
                %Events.PlayerDisconnected{
                  player: %{username: "Fergus"},
                  reason: :kicked_by_console
                }
              ]} = Parser.parse(kicked_by_console)
    end

    test "money change" do
      line =
        "12/11/2019 - 20:48:19.644 - \"Marvin<5><BOT><CT>\" money change 1400+3250 = $4650 (tracked)"

      assert {:ok,
              [
                %Events.MoneyChange{
                  player: %{username: "Marvin"},
                  previous: 1400,
                  diff: 3250,
                  result: 4650
                }
              ]} = Parser.parse(line)

      purchase =
        "12/11/2019 - 20:48:19.644 - \"Uri<8><BOT><CT>\" money change 3000-2000 = $1000 (tracked) (purchase: weapon_xm1014)"

      assert {:ok,
              [
                %Events.MoneyChange{
                  player: %{username: "Uri"},
                  previous: 3000,
                  diff: -2000,
                  result: 1000,
                  purchase: :xm1014
                }
              ]} = Parser.parse(purchase)
    end

    test "left buyzone" do
      line =
        "12/11/2019 - 20:48:19.644 - \"Fred<27><BOT><CT>\" left buyzone with [ weapon_knife weapon_hkp2000 weapon_c4 C4 ]"

      assert {:ok,
              [
                %Events.LeftBuyzone{
                  player: %{username: "Fred"},
                  weapons: [:knife, :hkp2000],
                  c4: true
                }
              ]} = Parser.parse(line)
    end

    test "picked up" do
      line = "12/11/2019 - 20:48:19.644 - \"George<21><BOT><CT>\" picked up \"hkp2000\""

      assert {:ok,
              [
                %Events.PickedUp{
                  player: %{username: "George"},
                  item: :hkp2000
                }
              ]} = Parser.parse(line)

      defuser = "12/11/2019 - 20:48:19.644 - \"George<21><BOT><CT>\" picked up \"defuser\""

      assert {:ok,
              [
                %Events.PickedUp{
                  player: %{username: "George"},
                  item: :defuser
                }
              ]} = Parser.parse(defuser)

      c4 = "12/11/2019 - 20:48:19.644 - \"George<21><BOT><CT>\" picked up \"c4\""

      assert {:ok,
              [
                %Events.PickedUp{
                  player: %{username: "George"},
                  item: :c4
                }
              ]} = Parser.parse(c4)
    end

    test "dropped" do
      line = "12/11/2019 - 20:48:19.644 - \"Wesley<16><BOT><TERRORIST>\" dropped \"glock\""

      assert {:ok,
              [
                %Events.Dropped{
                  player: %{username: "Wesley"},
                  item: :glock
                }
              ]} = Parser.parse(line)
    end

    test "purchased" do
      line = "12/11/2019 - 20:48:19.644 - \"Ryan<16><BOT><TERRORIST>\" purchased \"negev\""

      assert {:ok,
              [
                %Events.Purchased{
                  player: %{username: "Ryan"},
                  item: :negev
                }
              ]} = Parser.parse(line)

      line =
        "12/11/2019 - 20:48:19.644 - \"Ryan<16><BOT><TERRORIST>\" purchased \"item_assaultsuit\""

      assert {:ok,
              [
                %Events.Purchased{
                  player: %{username: "Ryan"},
                  item: :vesthelm
                }
              ]} = Parser.parse(line)
    end

    test "threw grenade" do
      line =
        "12/11/2019 - 20:48:19.644 - \"Wesley<16><BOT><TERRORIST>\" threw flashbang [1333 376 179] flashbang entindex 239)"

      assert {:ok,
              [
                %Events.ThrewGrenade{
                  player: %{username: "Wesley"},
                  item: :flashbang
                }
              ]} = Parser.parse(line)
    end
  end

  describe "multi-line parsing" do
    test "parses one event per line" do
      lines =
        "11/24/2019 - 21:43:39.781 - World triggered \"Game_Commencing\"\n11/24/2019 - 21:43:39.781 - World triggered \"Match_Start\" on \"de_inferno\"\n"

      assert {:ok, [%Events.GameCommencing{}, %Events.MatchStart{}]} = Parser.parse(lines)
    end

    test "skips unhandled events at the beginning" do
      lines =
        "11/24/2019 - 21:43:02.156 - Unhandled event\n11/24/2019 - 21:43:39.781 - World triggered \"Game_Commencing\"\n11/24/2019 - 21:43:39.781 - World triggered \"Match_Start\" on \"de_inferno\"\n"

      assert {:ok, [%Events.GameCommencing{}, %Events.MatchStart{}]} = Parser.parse(lines)
    end

    test "skips unhandled events in the middle" do
      lines =
        "11/24/2019 - 21:43:39.781 - World triggered \"Game_Commencing\"\n11/24/2019 - 21:43:02.156 - Unhandled event\n11/24/2019 - 21:43:39.781 - World triggered \"Match_Start\" on \"de_inferno\"\n"

      assert {:ok, [%Events.GameCommencing{}, %Events.MatchStart{}]} = Parser.parse(lines)
    end

    test "skips unhandled events at the end" do
      lines =
        "11/24/2019 - 21:43:39.781 - World triggered \"Game_Commencing\"\n11/24/2019 - 21:43:39.781 - World triggered \"Match_Start\" on \"de_inferno\"\n11/24/2019 - 21:43:02.156 - Unhandled event\n"

      assert {:ok, [%Events.GameCommencing{}, %Events.MatchStart{}]} = Parser.parse(lines)
    end
  end
end
