defmodule CsgoStats.Logs.Parser.RoundStart do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: World triggered "Round_Start"
  def parser() do
    ignore(string(~s/"Round_Start"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.RoundStart{}
  end
end
