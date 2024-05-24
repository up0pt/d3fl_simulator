defmodule WcMockHelper do
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS
  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.JobTilesExecutor
  alias D3flSimulator.JobTilesExecutor.JobTile
  alias D3flSimulator.Data

  def init_data_storage do
    {train_images, train_labels, test_images, test_labels} = MNISTDataLoader.load_data()
    DataStorage.start_link({train_images, train_labels, test_images, test_labels})
  end

  def init_q_list(elements) do
    queue = :queue.new()
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

  def list_dup(list, times) do
    Enum.reduce(1..times, list, fn _, acc -> acc ++ list end)
  end

  def q_list_plus_minus_1(node_id) do
    jt_q = init_q_list(
      list_dup(
        [
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> CalculatorNode.send_model_via_ch(node_id, node_id + 1)
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> CalculatorNode.send_model_via_ch(node_id, node_id - 1)
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          }
        ], 5)
    )
    jt_q
  end

  def q_list_plus_for_1() do
    node_id = 1
    jt_q = init_q_list(
      list_dup(
        [
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> CalculatorNode.send_model_via_ch(node_id, node_id + 1)
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          }
        ], 5)
    )
    jt_q
  end

  def q_list_plus_for_last(last_node_id) do
    node_id = last_node_id
    jt_q = init_q_list(
      list_dup(
        [
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 100,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> IO.puts("node #{node_id} do nothing")
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn time -> CalculatorNode.train(node_id, time) end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 20_000,
            wait_time_out: 5_000
          },
          %JobTile{
            task: fn _ -> CalculatorNode.send_model_via_ch(node_id, node_id - 1)
                  {:ok, nil}
                  end,
            feasible_start_time: 0.0,
            wall_clock_time_span: 4,
            wait_time_out: 5_000
          }
        ], 5)
    )
    jt_q
  end

  def num_mock(node_num) do
    init_data_storage()
    start = System.monotonic_time(:second)
    data_directory_path = prepare_data_directory!(node_num)

    JobTilesExecutor.start_link(%{node_num: node_num, from_pid: self()})
    Enum.each(1..node_num, fn num -> CalculatorNode.start_link(%{model: %{}, data: DataStorage.get_data(), node_index: num, data_directory_path: data_directory_path}) end)
    Enum.each(1..node_num-1, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num+1, latency: 0, packetloss: 0.5}}) end)
    Enum.each(2..node_num, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num-1, latency: 0, packetloss: 0.5}}) end)

    Enum.each(2..node_num-1, fn num -> JobTilesExecutor.init_job_tile_queue(%{node_id: num, job_tile_queue: q_list_plus_minus_1(num)}) end)
    JobTilesExecutor.init_job_tile_queue(%{node_id: 1, job_tile_queue: q_list_plus_for_1()})
    JobTilesExecutor.init_job_tile_queue(%{node_id: node_num, job_tile_queue: q_list_plus_for_last(node_num)})
    Enum.each(1..node_num, fn i -> JobTilesExecutor.exec(i) end)
    recieve_loop(0, node_num)
    last_time = System.monotonic_time(:second)

    IO.inspect(last_time - start)
    time_file_path = Path.join(data_directory_path, "exec_time.csv")
    {:ok, fp} = File.open(time_file_path, [:append, :utf8])
    IO.write(fp, "#{last_time - start} in sec\n")
    File.close fp
  end

  def num_mock_w_1loss(node_num) do
    init_data_storage()
    start = System.monotonic_time(:second)
    data_directory_path = prepare_data_directory!(node_num)

    JobTilesExecutor.start_link(%{node_num: node_num, from_pid: self()})
    Enum.each(1..node_num, fn num -> CalculatorNode.start_link(%{model: %{}, data: DataStorage.get_data(), node_index: num, data_directory_path: data_directory_path}) end)
    Enum.each(1..node_num-1, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num+1, latency: 0, packetloss: 1}}) end)
    Enum.each(2..node_num, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num-1, latency: 0, packetloss: 1}}) end)

    Enum.each(2..node_num-1, fn num -> JobTilesExecutor.init_job_tile_queue(%{node_id: num, job_tile_queue: q_list_plus_minus_1(num)}) end)
    JobTilesExecutor.init_job_tile_queue(%{node_id: 1, job_tile_queue: q_list_plus_for_1()})
    JobTilesExecutor.init_job_tile_queue(%{node_id: node_num, job_tile_queue: q_list_plus_for_last(node_num)})
    Enum.each(1..node_num, fn i -> JobTilesExecutor.exec(i) end)
    recieve_loop(0, node_num)
    last_time = System.monotonic_time(:second)

    IO.inspect(last_time - start)
    time_file_path = Path.join(data_directory_path, "exec_time.csv")
    {:ok, fp} = File.open(time_file_path, [:append, :utf8])
    IO.write(fp, "#{last_time - start} in sec\n")
    File.close fp
  end

  def num_mock_wo_loss(node_num) do
    init_data_storage()
    start = System.monotonic_time(:second)
    data_directory_path = prepare_data_directory!(node_num)

    JobTilesExecutor.start_link(%{node_num: node_num, from_pid: self()})
    Enum.each(1..node_num, fn num -> CalculatorNode.start_link(%{model: %{}, data: DataStorage.get_data(), node_index: num, data_directory_path: data_directory_path}) end)
    Enum.each(1..node_num-1, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num+1, latency: 0, packetloss: 0}}) end)
    Enum.each(2..node_num, fn num -> Channel.start_link({num, %InputQoS{send_node_id: num, recv_node_id: num-1, latency: 0, packetloss: 0}}) end)

    Enum.each(2..node_num-1, fn num -> JobTilesExecutor.init_job_tile_queue(%{node_id: num, job_tile_queue: q_list_plus_minus_1(num)}) end)
    JobTilesExecutor.init_job_tile_queue(%{node_id: 1, job_tile_queue: q_list_plus_for_1()})
    JobTilesExecutor.init_job_tile_queue(%{node_id: node_num, job_tile_queue: q_list_plus_for_last(node_num)})
    Enum.each(1..node_num, fn i -> JobTilesExecutor.exec(i) end)
    recieve_loop(0, node_num)
    last_time = System.monotonic_time(:second)

    IO.inspect(last_time - start)
    time_file_path = Path.join(data_directory_path, "exec_time.csv")
    {:ok, fp} = File.open(time_file_path, [:append, :utf8])
    IO.write(fp, "#{last_time - start} in sec\n")
    File.close fp
  end

  defp prepare_data_directory!(node_counts) do
    data_directory_path =
      Application.get_env(:d3fl_simulator, :data_directory_path) ||
        raise """
        You have to configure :data_directory_path in config.exs
        ex) config :ping_pong_measurer_Zenohex, :data_directory_path, "path/to/directory"
        """

    dt_string = Data.datetime_to_string(DateTime.utc_now())
    directory_name = "date_#{dt_string}_CalculatorNodeNum_#{node_counts}_newdata"
    data_directory_path = Path.join(data_directory_path, directory_name)

    File.mkdir_p!(data_directory_path)
    data_directory_path
  end
end
