import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

listen_port = String.to_integer(System.get_env("LISTEN_PORT") || "4000")
url_scheme = System.get_env("URL_SCHEME") || "http"
url_host = System.get_env("URL_HOST") || "localhost"

config :csgo_stats, CsgoStatsWeb.Endpoint,
  http: [port: listen_port],
  url: [
    scheme: url_scheme,
    host: url_host
  ],
  secret_key_base: secret_key_base
