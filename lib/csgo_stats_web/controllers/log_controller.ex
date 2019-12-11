defmodule CsgoStatsWeb.LogController do
  use CsgoStatsWeb, :controller
  require Logger

  def create(conn, _params) do
    with {:ok, body, conn} <- read_req_body(conn),
         metadata = headers_to_metadata(conn.req_headers),
         _ = log(metadata, body),
         :ok <- CsgoStats.Logs.process(body, metadata) do
      json(conn, "")
    else
      :restart_log ->
        conn
        |> put_status(205)
        |> json("")

      {:error, _} ->
        # TODO: Handle repeated failures by blocking requestor
        # Errors could be either invalid metadata or error on the socket
        # Could also return 410 to unsubscribe from game server logs
        conn
        |> put_status(400)
        |> json("")
    end
  end

  defp log(metadata, body) do
    Logger.debug("controller||#{Jason.encode!(metadata)}||#{String.replace(body, "\n", "|>")}")
  end

  defp read_req_body(conn, buffer \\ "") do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} -> {:ok, buffer <> body, conn}
      {:more, partial_body, conn} -> read_req_body(conn, buffer <> partial_body)
      {:error, _} = error -> error
    end
  end

  defp headers_to_metadata(headers) do
    headers
    |> Enum.reduce(%{}, fn header, acc ->
      case header do
        {"x-server-addr", server_address} ->
          Map.put(acc, :server_address, server_address)

        {"x-server-instance-token", server_instance_token} ->
          Map.put(acc, :server_instance_token, server_instance_token)

        {"x-steamid", steam_id} ->
          Map.put(acc, :steam_id, steam_id)

        {"x-timestamp", timestamp} ->
          Map.put(acc, :timestamp, timestamp)

        _header ->
          acc
      end
    end)
    |> Map.new()
  end
end
