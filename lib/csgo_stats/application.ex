defmodule CsgoStats.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    CsgoStats.Matches.DB.init()

    children = [
      CsgoStats.Matches.Supervisor,
      {Registry, keys: :unique, name: CsgoStats.Matches.EventHandler},
      {Registry, keys: :duplicate, name: CsgoStats.Matches.DB},
      # CsgoStats.Repo,
      CsgoStatsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CsgoStats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CsgoStatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
