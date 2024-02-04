defmodule D3flSimulator.Channel do
  use GenServer
  alias D3flSimulator.Utils
  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.CalculatorNode.SendDepend

  defmodule State do
    defstruct send_depend: nil,
              flag: nil,
              model: nil
  end

  def start_link(%SendDepend{} = arg_maps) do
    GenServer.start_link(
      __MODULE__,
      arg_maps,
      name: Utils.channel_name(arg_maps)
      )
  end

  def init(%SendDepend{} = arg_maps) do
    {
      :ok, %State{
        send_depend: arg_maps,
        flag: nil,
        model: nil
      }
    }
  end

  def get_model(%SendDepend{from: from_id} = send_maps) do
    Genserver.call(
      Utils.channel_name(send_maps),
      {:get_model, from_id},
      100_000
    )
  end

  # @doc """
  # ネットワーク品質の反映を行う関数
  # """
  # def affect_transfer(from_node_index,
  #                     to_node_index,
  #                     sending_model,
  #                     %State{
  #                       inputQoS: %InputQoS{
  #                         latency: _latency,
  #                         packetloss: packetloss
  #                       }
  #                       } = _state) do
  #   # Process.sleep(latency) # sleep for latency (in millisecond)
  #   new_model = loss_packet(packetloss, sending_model)
  #   CalculatorNode.recv_model(to_node_index, from_node_index, new_model)
  # end
#
  # def loss_packet(packetloss, model) do
  #   random_number = :rand.uniform()
  #   if random_number <= packetloss do
  #     nil
  #   else
  #     model
  #   end
  # end
#
  def handle_call({:get_model, from_id}, _from, state) do
    model = AiCore.get_current_model(from_id)
    {:reply, model, %State{state | flag: True, model: model}}
  end

  # def handle_call({:transfer_model,
  #                 from_node_index,
  #                 to_node_index,
  #                 sending_model},
  #                 _from,
  #                 state) do
  #   affect_transfer(from_node_index,
  #                   to_node_index,
  #                   sending_model,
  #                   state)
  #   {:reply, nil, state}
  #   # まだChannelのqueueはいじっていない
  #   # 理想的には，まずqueueに入れて，一定時間おきにpopしてaffect_transfer？
  # end
end
