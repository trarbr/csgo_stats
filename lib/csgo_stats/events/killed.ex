defmodule CsgoStats.Events.Killed do
  @derive {Jason.Encoder, only: [:killer,
    :killed,
    :weapon,
    :headshot,
    :penetrated]}
  defstruct [
    :killer,
    :killed,
    :weapon,
    :headshot,
    :penetrated
  ]
end
