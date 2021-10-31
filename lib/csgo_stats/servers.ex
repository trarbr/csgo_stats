defmodule CsgoStats.Servers do
  alias CsgoStats.Servers.{EventHandler, Supervisor}

  def event_handler_started?(server_instance_token) do
    case EventHandler.lookup(server_instance_token) do
      {:ok, _} -> true
      {:error, :not_found} -> false
    end
  end

  def start_event_handler(server_instance_token) do
    Supervisor.start_child({EventHandler, server_instance_token: server_instance_token})
  end

  def handle_events(server_instance_token, events) do
    # TODO: return error if the match starts in invalid state, e.g. if log is
    # started in the middle of a match
    case EventHandler.lookup(server_instance_token) do
      {:ok, event_handler} -> :ok = EventHandler.apply(event_handler, events)
      {:error, :not_found} -> {:error, :not_started}
    end
  end
end

# TODO:
# 1. Create server
# 2. Start server handlers
# 3. Handle logged events
