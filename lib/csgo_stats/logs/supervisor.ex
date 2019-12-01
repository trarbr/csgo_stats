defmodule CsgoStats.Logs.Supervisor do
  use Supervisor

  alias CsgoStats.Logs.Processor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children =
      0..(System.schedulers() - 1)
      |> Enum.map(fn scheduler ->
        {Processor, scheduler: scheduler}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
