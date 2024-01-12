defmodule D3flSimulator.JobTilesExecutor do
  use GenServer
  alias D3flSimulator.Utils
  alias D3flSimulator.JobTilesExecutor.Timer

  defmodule State do
    @enforce_key [:node_id]
    defstruct node_id: nil,
              wall_clock_time: 0.0, # wall clock time
              job_tile_queue: :queue.new,
              sim_wall_clock_rate: 1
  end

  defmodule JobTile do
    @enforce_key [:task, :wall_clock_time_span, :wait_time_out]
    defstruct task: nil,
              feasible_start_time: 0.0, # 0.0 means this task is done when poped
              dependent_task_list: [], #TODO: add dependency resolution mechanism
              wall_clock_time_span: 1, # how long the task take in wall clock time
              wait_time_out: 5_000
  end

  def start_link(%{node_num: num}) when is_integer(num) and num > 0 do
    Enum.each(
      1..num,
      fn node_id ->
      GenServer.start_link(
        __MODULE__,
        node_id,
        name: Utils.get_process_name(__MODULE__, node_id)
      )
      end
    )
  end

  def init(node_id) do
    children = [
      {Timer, %{node_id: node_id, pid: self()}}
    ]
    opts = [strategy: :one_for_one]
    {:ok, _id} = Supervisor.start_link(children, opts)

    {:ok,
    %State{
      node_id: node_id
    }}
  end

  def init_job_tile_queue(%{node_id: node_index, job_tile_queue: queue}) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      {:init_job_tile_queue, queue}
    )
  end

  def queue_out(job_tile_queue) do
    case :queue.len(job_tile_queue) do
      0 -> {{:value,
            %JobTile{
              task: fn -> IO.puts("executor is empty")
                    {:ok, nil}
                    end,
              wall_clock_time_span: 10_000,
              wait_time_out: 5_000
              }
            },
            job_tile_queue}
      _ -> :queue.out(job_tile_queue)
    end
  end

  defp wait_message do
    receive do
      {:message, content} ->
        IO.puts("\n Received message: #{content}")
      {:other_message} ->
        IO.puts("\n Received other message")
    end
  end

  def exec(node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      :exec,
      60_000
    )
  end

  def exec_in_loop(%State{
                      node_id: node_id,
                      job_tile_queue: queue,
                      sim_wall_clock_rate: time_rate
                    } = state) do

    {{:value, jobtile}, queue} = queue_out(queue)

    %JobTile{
      task: task,
      feasible_start_time: _f_start_time, # TODO: use this
      dependent_task_list: _task_list, # TODO: use this
      wall_clock_time_span: wc_span,
      wait_time_out: _w_time_out # TODO: use this
    } = jobtile

    Timer.start_timer(node_id, wc_span, time_rate)

    #TODO: task_list が空になったら...のロジックの整備．このままだと無理
    result = task.() # exec task

    #TODO: task はほとんどGenserver.callにする．
    # 理由は，うまくいったか行かないかを知り，タイムアウトも作動させたいから
    case result do
      {:ok, _response} -> nil
      {:error, reason} ->
        IO.puts("Error from server: #{reason}")
    end

    wait_message()

    exec_in_loop(%State{state |
      job_tile_queue: queue
    })
  end

  def handle_call({:init_job_tile_queue, queue}, _from, state) do
    {:reply, :ok, %State{state | job_tile_queue: queue}}
  end

  def handle_call(:exec, _from, state) do
    exec_in_loop(state)
    # 現状では無限ループになっているが，job_tiles_queueが空になったらおわってもいい？
    {:reply, :ok, state}
  end
end
