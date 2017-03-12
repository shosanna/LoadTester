defmodule LoadTester.CLI do
  alias LoadTester.TasksSupervisor
  require Logger

  def main(args) do
    Application.get_env(:load_tester, :master_node)
      |> Node.start

    Application.get_env(:load_tester, :slave_nodes)
      |> Enum.each(fn x -> Node.connect(x) end)

    args
      |> parse_args
      |> process_options([node()|Node.list])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(n, url, nodes)

      _ ->
        do_help()
    end
  end

  defp do_help do
    IO.puts """
      Usage:
      load_tester -n [requests] [url]

      Options:
      -n, [--requests]                 # Number of requests

      Example:
      ./load_tester -n 5 "http://journeyapp.net"
    """
    System.halt(0)
  end

  require IEx

  defp do_requests(n, url, nodes) do
    Logger.info "Pummeling #{url} with #{n} requests."
    total_nodes = Enum.count(nodes)
    req_per_node = div(n, total_nodes)

    Node.list
      |> Enum.flat_map(fn node ->
        1..req_per_node |> Enum.map(fn _ -> 
          Task.Supervisor.async({TasksSupervisor, node}, LoadTester.Worker, :start, [url]) end
        ) end
      )
      |> Enum.map(fn x -> Task.await(x, :infinity) end)
      |> parse_results
  end

  defp parse_results(results) do
    {successes, _failures} =
      results
        |> Enum.partition(fn x ->
          case x do
            {:ok, _ } -> true
            _         -> false
          end
        end )

    total_workers = Enum.count(results)
    total_success = Enum.count(successes)
    total_failure = total_workers - total_success

    data = successes |> Enum.map(fn {:ok, time } -> time end )
    average_time  = average(data)
    longest_time  = Enum.max(data)
    shortest_time = Enum.min(data)

    IO.puts """
      Total workers:       #{total_workers}
      Successful requests: #{total_success}
      Failed requests:     #{total_failure}
      Average (msec):      #{average_time}
      Longest (msec):      #{longest_time}
      Shortest (msec):     #{shortest_time}
    """
  end

  defp average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end
end
