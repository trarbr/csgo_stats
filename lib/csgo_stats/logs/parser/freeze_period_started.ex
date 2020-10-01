defmodule CsgoStats.Logs.Parser.FreezePeriodStarted do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: Starting Freeze period
  def parser() do
    ignore(string("Starting Freeze period"))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.FreezePeriodStarted{}
  end
end
