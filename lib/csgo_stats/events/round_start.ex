defmodule CsgoStats.Events.RoundStart do
  @type t() :: %__MODULE__{timestamp: NaiveDateTime.t()}
  defstruct [:timestamp]
end
