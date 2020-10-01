defmodule CsgoStats.Logs.Parser.Username do
  import NimbleParsec

  # Example: tbroedsgaard
  def parser() do
    utf8_string([{:not, ?<}], min: 1)
  end
end
