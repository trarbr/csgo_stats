use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the endpoint
config :csgo_stats, CsgoStatsWeb.Endpoint,
  server: false,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  static_url: [path: "/"],
  secret_key_base: "cEfaMdhkk8VZvdYxRby9MjB8Eek0b0yysYfVXwoV4ul5WzZfBRmWz6k0Bf5rhH4Q",
  render_errors: [view: CsgoStatsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CsgoStats.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "DDcvRhbPTARYZtDaxsNgNDoo0LzBilJB"
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if Mix.env() == :dev, do: import_config("dev.exs")
if Mix.env() == :test, do: import_config("test.exs")
