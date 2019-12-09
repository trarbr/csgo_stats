defmodule CsgoStats do
  @moduledoc """
  CsgoStats keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def playback(logfile) do
    spawn(fn -> do_playback(logfile) end)
  end

  def do_playback(logfile) do
    loglines =
      File.read!(logfile)
      |> String.split("\n")
      |> Enum.reject(fn logline -> logline == "" end)

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
        NaiveDateTime.diff(next_ts, first_ts, :millisecond)
      end)

    Enum.zip([loglines, sleep_intervals])
    |> Enum.each(fn {logline, sleep_interval} ->
      :httpc.request(
        :post,
        {'http://localhost:4000/api/logs',
         [
           {'x-server-addr', '0:0:0:0:12345'},
           {'x-server-instance-token', 'abcdefg'},
           {'x-steamid', '1'},
           {'x-timestamp', '1234'}
         ], 'text/plain', logline},
        [],
        []
      )

      Process.sleep(sleep_interval)
    end)
  end
end
