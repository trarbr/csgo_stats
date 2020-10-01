defmodule CsgoStats.Logs.Parser.RoundEnd do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: World triggered "Round_End"
  def parser() do
    ignore(string(~s/"Round_End"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.RoundEnd{}
  end
end
