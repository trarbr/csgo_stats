defmodule CsgoStats.Matches.MatchTest do
  use ExUnit.Case, async: true

  alias CsgoStats.Events
  alias CsgoStats.Matches

  @defaultState %Matches.Match{
    server_instance_token: "wizzy",
    phase: :pre_game,
    wins: [],
    players: %{},
    kill_feed: []
  }

  describe "Kill feed" do
    test "Adds kill to feed" do
      state = %{
        @defaultState
        | kill_feed: [
            %Events.Killed{
              killer: %{username: "Niles"},
              killed: %{username: "Elmer"},
              weapon: "glock",
              headshot: false,
              penetrated: false
            }
          ],
          players: %{
            "Elmer" => %Matches.Match.Player{},
            "Niles" => %Matches.Match.Player{}
          }
      }

      event = %Events.Killed{
        killer: %{username: "Niles"},
        killed: %{username: "Elmer"},
        weapon: "glock",
        headshot: false,
        penetrated: false
      }

      state = Matches.Match.apply(state, event)
      assert 2 = Enum.count(state.kill_feed)
    end

    test "Kill feed is cleared when round begins" do
      state = %{
        @defaultState
        | kill_feed: [
            %Events.Killed{
              killer: %{username: "Niles"},
              killed: %{username: "Elmer"},
              weapon: "glock",
              headshot: false,
              penetrated: false
            }
          ],
          players: %{
            "Elmer" => %Matches.Match.Player{},
            "Niles" => %Matches.Match.Player{}
          },
          phase: :round_over
      }

      state = Matches.Match.apply(state, %Events.FreezePeriodStarted{})
      assert 0 = Enum.count(state.kill_feed)
    end
  end
end
