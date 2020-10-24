use Mix.Config

config :csgo_stats, debug: Mix.env() == :dev

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the endpoint
config :csgo_stats, CsgoStatsWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  static_url: [path: "/"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "cEfaMdhkk8VZvdYxRby9MjB8Eek0b0yysYfVXwoV4ul5WzZfBRmWz6k0Bf5rhH4Q",
  render_errors: [view: CsgoStatsWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: CsgoStats.PubSub,
  live_view: [
    signing_salt: "DDcvRhbPTARYZtDaxsNgNDoo0LzBilJB"
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config("#{Mix.env()}.exs")
