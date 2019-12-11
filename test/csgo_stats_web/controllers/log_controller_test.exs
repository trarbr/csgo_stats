defmodule CsgoStatsWeb.LogControllerTest do
  use CsgoStatsWeb.ConnCase

  test "returns 205 when game server posts logs the first time, then 200", %{conn: conn} do
    body = "11/25/2019 - 20:20:38.763 - World triggered \"Game_Commencing\"\n"

    headers = [
      {"accept", "text/html,*/*;q=0.9"},
      {"accept-charset", "ISO-8859-1,utf-8,*;q=0.7"},
      {"accept-encoding", "gzip,identity,*;q=0"},
      {"content-length", "58"},
      {"content-type", "text/plain"},
      {"host", "localhost:4000"},
      {"user-agent", "Valve/Steam HTTP Client 1.0 (730)"},
      {"x-server-addr", "0.0.0.0:27015"},
      {"x-server-instance-token", "bugwu6cfwjkxh7fj"},
      {"x-steamid", "[A:1:3041094663:13679]"},
      {"x-tick-end", "1438"},
      {"x-tick-start", "1438"},
      {"x-timestamp", "11/25/2019 - 20:20:38.787"}
    ]

    conn =
      conn
      |> put_req_headers(headers)
      |> post("/api/logs", body)

    assert json_response(conn, 205) =~ ""

    conn =
      build_conn()
      |> put_req_headers(headers)
      |> post("/api/logs", body)

    assert json_response(conn, 200) =~ ""
  end

  defp put_req_headers(conn, headers) do
    Enum.reduce(headers, conn, fn {key, value}, conn ->
      put_req_header(conn, key, value)
    end)
  end
end
