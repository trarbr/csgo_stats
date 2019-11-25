defmodule CsgoStats.Repo do
  use Ecto.Repo,
    otp_app: :csgo_stats,
    adapter: Ecto.Adapters.Postgres
end
