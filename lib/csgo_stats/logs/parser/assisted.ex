defmodule CsgoStats.Logs.Parser.Assisted do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Elmer<18><BOT><CT>" assisted killing "Niles<16><BOT><TERRORIST>"
  def parser() do
    ignore(string(" assisted killing "))
    |> concat(Parser.Player.parser())
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([killed]) do
    %Events.Assisted{killed: killed}
  end
end
