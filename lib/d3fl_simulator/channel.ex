defmodule D3flSimulator.Channel do
  use GenServer
  alias D3flSimulator.Utils
  alias D3flSimulator.CalculatorNode

  defmodule InputQoS do
    defstruct send_node_id: 0,
              recv_node_id: 0,
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

  def start_link({_channel_index, %InputQoS{send_node_id: from_id, recv_node_id: to_id} = _inputQoS} = arg_tuples) do
    GenServer.start_link(
      __MODULE__,
      arg_tuples,
      name: Utils.get_process_name_from_to(__MODULE__, from_id, to_id)
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

  def transfer_model(from_node_index, to_node_index, sending_model) do
    GenServer.call(
      Utils.get_process_name_from_to(__MODULE__, from_node_index, to_node_index),
      {:transfer_model, from_node_index, to_node_index, sending_model}
    )
  end

  @doc """
  ネットワーク品質の反映を行う関数
  """
  def affect_transfer(from_node_index,
                      to_node_index,
                      sending_model,
                      %State{
                        inputQoS: %InputQoS{
                          latency: latency,
                          packetloss: packetloss
                        }
                        } = _state) do
    Process.sleep(latency) # sleep for latency (in millisecond)
    new_model = loss_packet(packetloss, sending_model)
    CalculatorNode.recv_model(to_node_index, from_node_index, new_model)
  end

  def loss_packet(packetloss, model) do
    random_number = :rand.uniform()
    if random_number <= packetloss do
      nil
    else
      model
    end
  end

  def change_input_latency(%{send_node_id: from_node_index, recv_node_id: to_node_index, latency: latency}) do
    GenServer.cast(
      Utils.get_process_name_from_to(__MODULE__, from_node_index, to_node_index),
      {:change_Input_latency, latency}
    )
  end

  def handle_call({:transfer_model,
                  from_node_index,
                  to_node_index,
                  sending_model},
                  _from,
                  state) do
    affect_transfer(from_node_index,
                    to_node_index,
                    sending_model,
                    state)
    {:reply, nil, state}
    # まだChannelのqueueはいじっていない
    # 理想的には，まずqueueに入れて，一定時間おきにpopしてaffect_transfer？
  end

  def handle_cast({:change_Input_latency,
                  latency_input},
                  %State{inputQoS: former_inputQoS} = state) do
    new_inputQoS = %InputQoS{former_inputQoS | latency: latency_input}
    {:noreply, %State{state | inputQoS: new_inputQoS}}
  end
end
