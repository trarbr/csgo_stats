defmodule CsgoStats.Events.FreezePeriodStarted do
  @type t() :: %__MODULE__{timestamp: NaiveDateTime.t()}
  defstruct [:timestamp]
end
