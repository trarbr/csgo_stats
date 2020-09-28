defmodule CsgoStats.Logs.Parser.GameCommencing do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: World triggered "Game_Commencing"
  def parser() do
    ignore(string(~s/"Game_Commencing"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.GameCommencing{}
  end
end
