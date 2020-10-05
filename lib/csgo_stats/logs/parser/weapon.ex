defmodule CsgoStats.Logs.Parser.Weapon do
  import NimbleParsec

  alias CsgoStats.Types

  @weapons Enum.map(Types.weapons(), fn weapon ->
             string(to_string(weapon))
           end)

  # Example: "glock"
  def parser() do
    ignore(string(~s/"/))
    |> concat(weapon())
    |> ignore(string(~s/"/))
  end

  def prefixed() do
    ignore(string("weapon_"))
    |> concat(weapon())
  end

  defp weapon() do
    choice(@weapons)
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([weapon]) do
    String.to_existing_atom(weapon)
  end
end
