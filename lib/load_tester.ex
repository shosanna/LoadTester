defmodule LoadTester do
  @moduledoc """
  Documentation for LoadTester.
  """

  @doc """
  Measure the response time of a n GET requests for given url.

  ## Examples

      iex> LoadTester.run(5, 'http://google.com')
      [{:ok, 212.233}, {:ok, 130.746}, {:ok, 126.054}, {:ok, 187.325}, {:ok, 159.102}]

  """
  def run(n_workers, url) when n_workers > 0 do
    worker_func = fn -> LoadTester.Worker.start(url) end

    1..n_workers
      |> Enum.map(fn _ -> Task.async(worker_func) end)
      |> Enum.map(fn x -> Task.await(x) end)
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
