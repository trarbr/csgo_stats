defmodule CsgoStats.Logs.Parser.Player do
  import NimbleParsec

  alias CsgoStats.Logs.Parser

  # Example: "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>"
  def parser() do
    ignore(string(~s/"/))
    |> concat(Parser.Username.parser())
    |> concat(Parser.UserTag.parser())
    |> concat(steam_id())
    |> concat(optional(Parser.TeamTag.parser()))
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: <STEAM_1:1:42376214>
  defp steam_id() do
    ignore(string("<"))
    |> choice([string("BOT"), utf8_string([{:not, ?>}], min: 1)])
    |> ignore(string(">"))
  end

  def cast([username, _tag, steam_id]) do
    %{username: username, steam_id: steam_id, team: nil}
  end

  def cast([username, _tag, steam_id, team]) do
    %{username: username, steam_id: steam_id, team: team}
  end
end
