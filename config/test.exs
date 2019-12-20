use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :csgo_stats, CsgoStatsWeb.Endpoint,
  server: false,
  http: [port: 4002],
  cache_static_manifest: nil

# Print only warnings and errors during test
config :logger, level: :warn
