Logger.configure(level: :warn)

local_log_to_server_log = fn filename ->
  File.read!(filename)
  |> String.split("\n")
  |> Enum.map(&CsgoStats.ensure_http_log_format/1)
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
