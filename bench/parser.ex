Logger.configure(level: :warn)

local_log_to_server_log = fn filename ->
  File.read!(filename)
  |> String.split("\n")
  |> Enum.map(fn
    <<"L ", local_log::binary>> -> String.replace(local_log, ": ", ".000 - ")
    server_log -> server_log
  end)
  |> Enum.join("\n")
end

inputs =
  Path.wildcard("bench/inputs/*.log")
  |> Map.new(fn file ->
    {Path.basename(file), local_log_to_server_log.(file)}
  end)

Benchee.run(
  %{
    "base" => fn input -> CsgoStats.Logs.Parser.parse(input) end
  },
  inputs: inputs
)
