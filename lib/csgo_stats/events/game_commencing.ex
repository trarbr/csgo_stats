defmodule CsgoStats.Events.GameCommencing do
  @type t() :: %__MODULE__{timestamp: NaiveDateTime.t()}
  defstruct [:timestamp]
end
