defmodule CsgoStats.Logs.Parser.PlayerConnected do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Uri<13><BOT><>" connected, address ""
  def parser() do
    ignore(string(~s/ connected, address "/))
    |> optional(utf8_string([{:not, ?"}], min: 1))
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.PlayerConnected{}
  end

  def cast([address]) do
    %Events.PlayerConnected{address: address}
  end
end
