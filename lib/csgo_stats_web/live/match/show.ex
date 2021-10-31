defmodule CsgoStatsWeb.MatchLive.Show do
  use CsgoStatsWeb, :live_view

  alias CsgoStats.Servers.EventHandler
  alias CsgoStats.Matches.Match
  alias CsgoStats.Matches.Match.Player

  def mount(%{"id" => server_instance_token}, _session, socket) do
    match =
      CsgoStats.Matches.get_match(server_instance_token) ||
        Match.new(server_instance_token)

    CsgoStats.Matches.subscribe_match(server_instance_token)
    match = %{match | players: sort_players(match.players)}

    {:ok, assign(socket, match: match)}
  end

  def handle_event("set-event", %{"event-selector" => event}, socket) do
    event_index = String.to_integer(event)
    EventHandler.replay_from_event(socket.assigns.match.server_instance_token, event_index)

    {:noreply, socket}
  end

  def handle_info({:match_updated, match}, socket) do
    match = %{match | players: sort_players(match.players)}

    {:noreply, assign(socket, match: match)}
  end

  defp sort_players(players) do
    Enum.sort(players, fn {_, a}, {_, b} ->
      a.kills + a.assists / 100 - a.deaths / 1000 >= b.kills + b.assists / 100 - b.deaths / 1000
    end)
  end

  defp timer_class(match) do
    case match.phase do
      :freeze_period -> "red"
      :round_started -> ""
      :bomb_planted -> "red"
      _ -> "hide"
    end
  end

  defp formatted_time_left(nil), do: ""

  defp formatted_time_left(time_left) do
    minutes = floor(time_left / 60)

    seconds =
      (time_left - minutes * 60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{minutes}:#{seconds}"
  end

  defp bomb_class(match) do
    case match.phase do
      :bomb_planted -> "shown"
      {:round_over, :target_bombed} -> "shown"
      {:round_over, :bomb_defused} -> "shown defused"
      _ -> ""
    end
  end

  defp player_class(%Player{health: 0}), do: "dead"
  defp player_class(_), do: ""

  defp events(match) do
    {processed_events, received_events} = EventHandler.get_events(match.server_instance_token)

    "#{Enum.count(processed_events)}/#{Enum.count(received_events)}"
  end
end
