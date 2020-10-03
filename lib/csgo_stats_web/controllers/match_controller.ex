defmodule CsgoStatsWeb.MatchController do
  use CsgoStatsWeb, :controller

  alias CsgoStatsWeb.MatchLive

  def index(conn, _params) do
    live_render(conn, MatchLive.Index, session: %{})
  end

  def show(conn, params) do
    live_render(conn, MatchLive.Show, session: %{"server_instance_token" => params["id"]})
  end
end
