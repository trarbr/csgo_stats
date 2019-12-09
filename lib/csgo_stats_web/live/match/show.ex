defmodule CsgoStatsWeb.MatchLive.Show do
  use Phoenix.LiveView

  def mount(params, socket) do
    match =
      CsgoStats.Matches.get_match(params.server_instance_token) ||
        CsgoStats.Matches.Match.new(params.server_instance_token)

    CsgoStats.Matches.DB.subscribe_match(params.server_instance_token)

    {:ok, assign(socket, match: match)}
  end

  def render(assigns) do
    CsgoStatsWeb.MatchView.render("show.html", assigns)
  end

  def handle_info({:match_updated, match}, socket) do
    {:noreply, assign(socket, match: match)}
  end
end
