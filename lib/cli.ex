use Mix.config
defmodule LoadTester.CLI do
  require Logger

  def main(args) do
    Application.get_env(:load_tester, :master_node)
      |> Node.start

    Application.get_env(:load_tester, :slave_nodes)
      |> Enum.each(fn x -> Node.connect(x) end)

    args
      |> parse_args
      |> process_options([node|Node.list])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests], strict: [:requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} -> do_requests(n, url, nodes)
      _ -> do_help
    end
  end

  defp do_help do
    IO.puts """
      Usage:
      load_tester -n [requests] [url]

      Options:
      -n, [--requests]                 # Number of requests

      Example:
      ./load_tester 5 "http://journeyapp.net"
    """
    System.halt(0)
  end

  defp do_requests(n, url, nodes) do
    Logger.info "Pummeling #{url} with #{n} requests."
    total_nodes = Enum.count(nodes)
    req_per_node = div(n, total_nodes)

    nodes
      |> Enum.flat_map(fn node ->
        1..req_per_node |> Enum.map(fn _ -> 
          Task.Supervisor.async({LoadTester.TaskSupervisor, node}, LoadTester.Worker, :start, [url]) end
        ) end
      )
      |> Enum.map(fn x -> Task.await(x, :infinity) end)
      |> parse_results
  end
end
