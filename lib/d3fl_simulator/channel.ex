defmodule D3flSimulator.Channel do
  use GenServer
  alias D3flSimulator.Utils

  defmodule InputQoS do
    defstruct send_node: 0,
              recv_node: 0,
              uptime: 1_000,
              jitter: 0,
              latency: 0,
              max_bandwidth: 1_000,
              packetloss: 0,
              protocol: "sample"
  end

  defmodule State do
    defstruct channel_index: 0,
              inputQoS: nil,
              queue: nil
  end

  def start_link({channel_index, %InputQoS{} = _inputQoS} = arg_tuples) do
    GenServer.start_link(
      __MODULE__,
      arg_tuples,
      name: Utils.get_process_name(__MODULE__, channel_index)
      )
  end

  def init({channel_index, %InputQoS{} = inputQoS}) do
    queue = :queue.new
    {
      :ok, %State{
        channel_index: channel_index,
        inputQoS: inputQoS,
        queue: queue
      }
    }
  end


end
