defmodule D3flSimulator.JobTilesExecutor.Timer do
  use GenServer
  alias D3flSimulator.Utils

  defmodule State do
    defstruct node_id: nil,
              job_tile_exec_pid: nil
  end

  def start_link(%{node_id: node_id, pid: _pid} = arg_map) do
    GenServer.start_link(
      __MODULE__,
      arg_map,
      name: Utils.get_process_name(__MODULE__, node_id)
    )
  end

  def init(%{node_id: node_id, pid: pid}) do
    {:ok,
    %State{
      node_id: node_id,
      job_tile_exec_pid: pid
    }}
  end

  def start_timer(node_id, wall_clock_span, rate) do
    GenServer.cast(
      Utils.get_process_name(__MODULE__, node_id),
      {:start_timer, wall_clock_span, rate}
    )
  end

  def handle_cast({:start_timer, wall_clock_span, rate}, %State{job_tile_exec_pid: pid} = state) do
    Process.sleep(round(wall_clock_span / rate))
    send(pid, {:message, :ok})
    {:noreply, state}
  end
end
