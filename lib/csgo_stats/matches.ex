defmodule CsgoStats.Matches do
  alias CsgoStats.Matches.{DB, EventHandler, Supervisor}

  def list_matches() do
    DB.list()
  end

  def get_match(server_instance_token) do
    DB.get(server_instance_token)
  end

  def apply(server_instance_token, events) do
    case EventHandler.lookup(server_instance_token) do
      {:ok, event_handler} ->
        EventHandler.apply(event_handler, events)

      {:error, :not_found} ->
        Supervisor.start_child(
          {EventHandler, server_instance_token: server_instance_token, events: events}
        )
    end
  end
end
