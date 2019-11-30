defmodule CsgoStats.Events.Killed do
  defstruct [
    :killer,
    :killed,
    :weapon,
    :headshot,
    :penetrated
  ]
end
