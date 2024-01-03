defmodule MockHelper do
  require Logger

  alias D3flSimulator.ComputerNode
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS

  @spec start_mock() :: :ok
  def start_mock() do
    ComputerNode.start_link({"a", "b", 1})
    ComputerNode.start_link({"c", "d", 2})
    ComputerNode.start_link({"e", "f", 3})

    Channel.start_link({0, %InputQoS{send_node_id: 1, recv_node_id: 2, latency: 0, packetloss: 1}})
    Channel.start_link({1, %InputQoS{send_node_id: 3, recv_node_id: 2, latency: 0}})
    Channel.start_link({2, %InputQoS{send_node_id: 2, recv_node_id: 1, latency: 0}})

    ComputerNode.send_model_via_ch(1, 2)
    ComputerNode.send_model_via_ch(3, 2)
    ComputerNode.send_model_via_ch(2, 1)
    Process.sleep(3000)
    ComputerNode.get_info(2)
  end
end
