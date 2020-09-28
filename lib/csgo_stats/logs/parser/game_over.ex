defmodule CsgoStats.Logs.Parser.GameOver do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: Game Over: casual mg_de_inferno de_inferno score 3:8 after 18 min
  def parser() do
    ignore(string("Game Over: "))
    |> concat(game_mode())
    |> ignore(string(" "))
    |> ignore(ascii_string([?a..?z, ?_], min: 1))
    |> ignore(string(" "))
    |> concat(Parser.GameMap.parser())
    |> ignore(string(" score "))
    |> integer(min: 1)
    |> ignore(string(":"))
    |> integer(min: 1)
    |> ignore(string(" after "))
    |> integer(min: 1)
    |> ignore(string(" min"))
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: "casual"
  defp game_mode() do
    choice([
      string("casual"),
      string("competitive")
    ])
  end

  def cast([game_mode, game_map, ct_score, t_score, duration]) do
    game_mode =
      case game_mode do
        "casual" -> :casual
        "competetive" -> :competetive
      end

    %Events.GameOver{
      game_mode: game_mode,
      game_map: game_map,
      ct_score: ct_score,
      t_score: t_score,
      duration: duration
    }
  end
end
