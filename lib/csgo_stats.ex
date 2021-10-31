defmodule CsgoStats do
  @moduledoc """
  CsgoStats keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def debug?() do
    Application.get_env(:csgo_stats, :debug, false)
  end

  def load(logfile) do
    loglines =
      File.read!(logfile)
      |> String.split("\n")
      |> Enum.reject(fn logline -> logline == "" end)
      |> Enum.map(&ensure_http_log_format/1)
      |> Enum.join("\n")

    {:ok, events} = CsgoStats.Logs.Parser.parse(loglines)

    id = String.replace(logfile, "/", "-")
    CsgoStats.Servers.start_event_handler("load-" <> id)
    CsgoStats.Servers.handle_events("load-" <> id, events)
  end

  def playback(logfile, speedup \\ 1, url \\ 'http://localhost:4000/api/logs') do
    spawn(fn -> do_playback(logfile, url, speedup) end)
  end

  def do_playback(logfile, url, speedup) do
    loglines =
      File.read!(logfile)
      |> String.split("\n")
      |> Enum.reject(fn logline -> logline == "" end)
      |> Enum.map(&ensure_http_log_format/1)

    timestamps =
      loglines
      |> Enum.map(fn logline ->
        {:ok, date} =
          String.slice(logline, 0, 10)
          |> String.split("/")
          |> Enum.map(&String.to_integer/1)
          |> (fn [month, day, year] -> Date.new(year, month, day) end).()

        {:ok, time} =
          String.slice(logline, 13, 12)
          |> String.split(":")
          |> (fn [hour, minute, rest] ->
                [second, millisecond] = String.split(rest, ".")
                [hour, minute, second, millisecond]
              end).()
          |> Enum.map(&String.to_integer/1)
          |> (fn [hour, minute, second, millisecond] ->
                Time.new(hour, minute, second, millisecond * 1000)
              end).()

        {:ok, timestamp} = NaiveDateTime.new(date, time)
        timestamp
      end)

    [_first_timestamp | rest] = timestamps

    sleep_intervals =
      Enum.zip([timestamps, rest])
      |> Enum.map(fn {first_ts, next_ts} ->
        diff = NaiveDateTime.diff(next_ts, first_ts, :millisecond)
        trunc(diff / speedup)
      end)

    id = String.replace(logfile, "/", "-")

    Enum.zip([loglines, sleep_intervals])
    |> Enum.each(fn {logline, sleep_interval} ->
      {:ok, _} =
        :httpc.request(
          :post,
          {url,
           [
             {'x-server-addr', '0:0:0:0:12345'},
             {'x-server-instance-token', String.to_charlist("playback-" <> id)},
             {'x-steamid', '1'},
             {'x-timestamp', '1234'}
           ], 'text/plain', logline},
          [],
          []
        )

      Process.sleep(sleep_interval)
    end)
  end

  def format_timestamp(ts) do
    {millis, _} = ts.microsecond

    pad(ts.month) <>
      "/" <>
      pad(ts.day) <>
      "/" <>
      pad(ts.year) <>
      " - " <>
      pad(ts.hour) <>
      ":" <>
      pad(ts.minute) <>
      ":" <>
      pad(ts.second) <>
      "." <>
      pad(div(millis, 1000))
  end

  def pad(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  def ensure_http_log_format(line) do
    # If the line is prefixed with `L `, translate from local log format to
    # HTTP log format. The translation removes the `L ` prefix, adds
    # milliseconds to the timestamp and changes the delimiter between timestamp
    # and log message. E.g. `L 12/30/2019 - 17:51:08: ` is changed to
    # `12/30/2019 - 17:51:08.000 - `.
    case line do
      <<"L ", local_log::binary>> -> Regex.replace(~r/(?<=:\d\d): /, local_log, ".000 - ")
      server_log -> server_log
    end
  end
end
