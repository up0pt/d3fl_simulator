defmodule D3flSimulator.JobTilesExecutor do
  use GenServer
  alias D3flSimulator.Utils

  defmodule State do
    @enforce_key [:node_id]
    defstruct node_id: nil,
              wall_clock_time: 0.0, # wall clock time
              job_tile_queue: :queue.new
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
      0..num-1,
      fn node_id -> GenServer.start_link(
        __MODULE__,
        node_id,
        name: Utils.get_process_name(__MODULE__, node_id)
      )
      end
    )
    IO.puts("start_job_tile_exec")
  end

  def init(node_id) do
    IO.puts("#id #{node_id}: initialized")
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
      :exec
    )
  end

  def handle_call({:init_job_tile_queue, queue}, _from, state) do
    {:reply, :ok, %State{state | job_tile_queue: queue}}
  end

  def handle_call(:exec, _from, %State{job_tile_queue: queue} = state) do
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
    task.() # exec task

    {:reply, :ok, %State{state | job_tile_queue: queue}}
  end
end
