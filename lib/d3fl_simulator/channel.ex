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

  def change_inputQoS(%InputQoS{send_node_id: from_node_index, recv_node_id: to_node_index} = inputQoS) do
    GenServer.cast(
      Utils.get_process_name_from_to(__MODULE__, from_node_index, to_node_index),
      {:change_InputQoS, inputQoS}
    )
  end

  def get_info(from_node_id, to_node_id) do
    GenServer.call(
      Utils.get_process_name_from_to(__MODULE__, from_node_id, to_node_id),
      {:get_info}
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

  def handle_call({:get_info}, _from, %State{inputQoS: inputQoS} = state) do
    IO.inspect(inputQoS)
    {:reply, nil, state}
  end

  def handle_cast({:change_InputQoS,
                  inputQoS},
                  %State{inputQoS: former_inputQoS} = state) do
    former_inputQoS_map = Map.from_struct(former_inputQoS)
    inputQoS_map = Map.from_struct(inputQoS)

    updated_inputQoS_map = Enum.reduce(inputQoS_map, former_inputQoS_map, fn {key, value}, acc_map ->
      Map.update(acc_map, key, value, fn _existing_value -> value end)
    end)
    new_inputQoS = struct(InputQoS, updated_inputQoS_map)
    {:noreply, %State{state | inputQoS: new_inputQoS}}
  end
end
