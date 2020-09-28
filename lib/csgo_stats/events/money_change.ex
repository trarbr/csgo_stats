defmodule CsgoStats.Events.MoneyChange do
  defstruct [:player, :previous, :diff, :result, :purchase, :timestamp]
end
