use Mix.config
defmodule LoadTester.CLI do
  require Logger

  def main(args) do
    args
      |> parse_args
      |> process_options
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests], strict: [:requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} -> #perform action
      _ -> do_help
    end
  end
end
