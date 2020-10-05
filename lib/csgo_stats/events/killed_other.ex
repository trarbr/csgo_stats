defmodule CsgoStats.Events.KilledOther do
  alias CsgoStats.Types

  @type t() :: %__MODULE__{
          killed: Types.player(),
          killed: Types.killable(),
          weapon: Types.weapon(),
          headshot: boolean(),
          penetrated: boolean(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:killer, :killed, :weapon, :headshot, :penetrated, :timestamp]
end
