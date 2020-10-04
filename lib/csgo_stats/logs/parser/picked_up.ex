defmodule CsgoStats.Logs.Parser.PickedUp do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "George<21><BOT><CT>" picked up "hkp2000"
  def parser() do
    ignore(string(" picked up "))
    |> choice([
      Parser.Weapon.parser(),
      defuser()
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  defp defuser() do
    ignore(string(~s/"defuser"/))
    |> reduce({__MODULE__, :cast_defuser, []})
  end

  def cast_defuser([]) do
    :defuser
  end

  def cast([item]) do
    %Events.PickedUp{item: item}
  end
end
