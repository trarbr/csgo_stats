defmodule CsgoStats.Logs.Parser.GameMap do
  import NimbleParsec

  # Example: "de_inferno"
  def parser() do
    choice([
      string("de_cache"),
      string("de_vertigo"),
      string("de_dust2"),
      string("de_inferno"),
      string("de_mirage"),
      string("de_nuke"),
      string("de_overpass"),
      string("de_train")
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([map]) do
    case map do
      "de_cache" -> :de_cache
      "de_vertigo" -> :de_vertigo
      "de_dust2" -> :de_dust2
      "de_inferno" -> :de_inferno
      "de_mirage" -> :de_mirage
      "de_nuke" -> :de_nuke
      "de_overpass" -> :de_overpass
      "de_train" -> :de_train
    end
  end
end
