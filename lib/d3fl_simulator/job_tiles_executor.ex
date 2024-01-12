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
    @enforce_key [:task, :wait_time_out]
    defstruct task: nil,
              feasible_start_time: 0.0, # 0.0 means this task is done when poped
              dependent_task_list: [], #TODO: add dependency resolution mechanism
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
              task: fn -> IO.puts("executor is empty") end,
              wait_time_out: 5_000
              }
            },
            job_tile_queue}
      _ -> :queue.out(job_tile_queue)
    end
  end

  def exec(node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      :exec,
      600_000
    )
  end

  def handle_call({:init_job_tile_queue, queue}, _from, state) do
    {:reply, :ok, %State{state | job_tile_queue: queue}}
  end

  def handle_call(:exec, _from, %State{job_tile_queue: queue, sim_wall_clock_rate: time_rate} = state) do


    {{:value, jobtile}, queue} = queue_out(queue)

    %JobTile{
      task: task,
      feasible_start_time: f_start_time,
      dependent_task_list: task_list,
      wait_time_out: w_time_out
    } = jobtile

    #TODO: add the codes like this;
    # if f_start_time < wall_clock_time
    # then sleep(f_start_time - wall_clock_time)
    #
    # while task_list ~~~
    #TODO: task_list が空になったら...のロジックの整備．このままだと無理
    result = task.() # exec task
    case result do
      {:ok, response} -> nil
      {:error, reason} ->
        IO.puts("Error from server: #{reason}")
    end
    #TODO: task はほとんどGenserver.callにする．
    # 理由は，うまくいったか行かないかを知り，タイムアウトも作動させたいから
    {:reply, :ok, %State{state | job_tile_queue: queue}}
  end
end
