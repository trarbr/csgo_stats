defmodule CsgoStats.Logs.Parser.GameMap do
  import NimbleParsec

  alias CsgoStats.Types

  @maps Enum.map(Types.game_maps(), fn map ->
          string(to_string(map))
        end)

  # Example: "de_inferno"
  def parser() do
    choice(@maps)
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([map]) do
    String.to_existing_atom(map)
  end
end
