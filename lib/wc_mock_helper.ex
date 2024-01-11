defmodule WcMockHelper do
  alias D3flSimulator.WallClock
  alias D3flSimulator.JobTilesExecutor

  def init_q_list(elements) do
    queue = :queue.new
    Enum.reduce(elements, queue, fn element, acc_queue ->
      :queue.in(element, acc_queue)
    end)
  end

  def start_mock() do
    JobTilesExecutor.start_link(%{node_num: 3})

    jt_q_0 = init_q_list(
      [
        %JobTile{
          task: fn -> IO.puts("node_0 task 1"),
          feasible_start_time: 0.0,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> IO.puts("node_0 task 2"),
          feasible_start_time: 0.0,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> IO.puts("node_0 task 3"),
          feasible_start_time: 0.0,
          wait_time_out: 5_000
        },
      ]
    )

    JobTilesExecutor.init_job_tile_queue(%{node_id: 0, job_tile_queue: jt_q_0})

    WallClock.start()
  end
end
