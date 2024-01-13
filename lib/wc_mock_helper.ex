defmodule WcMockHelper do
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS
  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.JobTilesExecutor
  alias D3flSimulator.JobTilesExecutor.JobTile
  alias D3flSimulator.WallClock
  alias D3flSimulator.Data

  def init_q_list(elements) do
    queue = :queue.new
    Enum.reduce(elements, queue, fn element, acc_queue ->
      :queue.in(element, acc_queue)
    end)
  end

  def recieve_loop(empty_num, all_node_num) when empty_num < all_node_num do
    receive do
      {:queue_empty, node_id} ->
        IO.puts("\n empty queue: pid #{node_id}")
        recieve_loop(empty_num + 1, all_node_num)

      {:other_message} ->
        IO.puts("\n Received other message")
    end
  end

  def recieve_loop(empty_num, all_node_num) when empty_num >= all_node_num do
    IO.puts("\n all queues are empty")
  end

  def start_mock() do
    node_num = 3
    data_directory_path = prepare_data_directory!(node_num = 3)

    JobTilesExecutor.start_link(%{node_num: node_num, from_pid: self()})
    CalculatorNode.start_link(%{model: %{}, data: "b", node_index: 1})
    CalculatorNode.start_link(%{model: %{}, data: "d", node_index: 2})
    CalculatorNode.start_link(%{model: %{}, data: "f", node_index: 3})

    Channel.start_link({0, %InputQoS{send_node_id: 1, recv_node_id: 2, latency: 0, packetloss: 1}})
    Channel.start_link({1, %InputQoS{send_node_id: 3, recv_node_id: 2, latency: 0}})
    Channel.start_link({2, %InputQoS{send_node_id: 2, recv_node_id: 1, latency: 0}})

    jt_q_1 = init_q_list(
      [
        %JobTile{
          task: fn -> IO.puts("node 1 task 1")
                {:ok, nil}
                end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 3,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> CalculatorNode.train(1) end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 20_000,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> IO.puts("node 1 task 3")
                {:ok, nil}
                end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 3,
          wait_time_out: 5_000
        }
      ]
    )

    jt_q_2 = init_q_list(
      [
        %JobTile{
          task: fn -> CalculatorNode.train(2) end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 20_000,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> IO.puts("node 2 task 2")
                {:ok, nil}
                end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 3,
          wait_time_out: 5_000
        }
      ]
    )

    jt_q_3 = init_q_list(
      [
        %JobTile{
          task: fn -> CalculatorNode.train(3) end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 20_000,
          wait_time_out: 5_000
        },
        %JobTile{
          task: fn -> IO.puts("node 3 task 2")
                {:ok, nil}
                end,
          feasible_start_time: 0.0,
          wall_clock_time_span: 3,
          wait_time_out: 5_000
        }
      ]
    )

    JobTilesExecutor.init_job_tile_queue(%{node_id: 1, job_tile_queue: jt_q_1})
    JobTilesExecutor.init_job_tile_queue(%{node_id: 2, job_tile_queue: jt_q_2})
    JobTilesExecutor.init_job_tile_queue(%{node_id: 3, job_tile_queue: jt_q_3})


    Enum.each(1..3, fn i -> JobTilesExecutor.exec(i) end)
    recieve_loop(0, node_num)
  end

  defp prepare_data_directory!(node_counts) do
    data_directory_path =
      Application.get_env(:d3fl_simulator, :data_directory_path) ||
        raise """
        You have to configure :data_directory_path in config.exs
        ex) config :ping_pong_measurer_Zenohex, :data_directory_path, "path/to/directory"
        """

    dt_string = Data.datetime_to_string(DateTime.utc_now())
    directory_name = "date_#{dt_string}_CalculatorNode_#{node_counts}"
    data_directory_path = Path.join(data_directory_path, directory_name)

    File.mkdir_p!(data_directory_path)
    data_directory_path
  end
end
