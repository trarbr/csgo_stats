defmodule CsgoStats.Logs.Parser.Team do
  import NimbleParsec

  alias CsgoStats.Types

  # Example: CT
  def parser() do
    choice([
      string("CT"),
      string("TERRORIST"),
      string("T"),
      string("Unassigned"),
      string("Spectator")
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  Enum.each(Types.teams(), fn
    :ct -> defp cast_team("CT"), do: :ct
    :terrorist -> defp cast_team(team) when team in ["T", "TERRORIST"], do: :terrorist
    :unassigned -> defp cast_team("Unassigned"), do: :unassigned
    :spectator -> defp cast_team("Spectator"), do: :spectator
  end)

  def cast([team]) do
    cast_team(team)
  end
end
