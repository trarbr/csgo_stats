defmodule CsgoStats.Logs do
  require Logger

  alias CsgoStats.Logs.{Entry, Processor}

  def process(data, metadata) do
    case Entry.new(data, metadata) do
      {:ok, entry} ->
        :ok = Processor.enqueue(entry)

      {:error, :invalid_metadata} = error ->
        Logger.warn([
          "invalid_metadata||",
          Jason.encode!(metadata),
          "||",
          String.replace(data, "\n", "|>")
        ])

        error
    end
  end
end
