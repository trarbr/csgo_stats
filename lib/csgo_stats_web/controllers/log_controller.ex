defmodule CsgoStatsWeb.LogController do
  use CsgoStatsWeb, :controller

  def create(conn, _params) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn),
         metadata = headers_to_metadata(conn.req_headers) do
      # TODO: Handle repeated failures as a result of bad metadata by blocking requestor
      _ = CsgoStats.Logs.process(body, metadata)
      json(conn, "")
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
