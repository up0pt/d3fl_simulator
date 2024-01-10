defmodule MockHelper do
  require Logger

  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS

  @spec start_mock() :: :ok
  def start_mock() do
    CalculatorNode.start_link({%{}, "b", 1})
    CalculatorNode.start_link({%{}, "d", 2})
    CalculatorNode.start_link({%{}, "f", 3})

    Channel.start_link({0, %InputQoS{send_node_id: 1, recv_node_id: 2, latency: 0, packetloss: 1}})
    Channel.start_link({1, %InputQoS{send_node_id: 3, recv_node_id: 2, latency: 0}})
    Channel.start_link({2, %InputQoS{send_node_id: 2, recv_node_id: 1, latency: 0}})

    CalculatorNode.train(1)
    CalculatorNode.train(2)
    CalculatorNode.train(3)
    Process.sleep(10000)


    Channel.change_input_latency(%{send_node_id: 3, recv_node_id: 2, latency: 5})
    CalculatorNode.send_model_via_ch(1, 2)
    CalculatorNode.send_model_via_ch(3, 2)
    CalculatorNode.send_model_via_ch(2, 1)
    Process.sleep(10000)

    CalculatorNode.train(1)
    CalculatorNode.train(2)
    CalculatorNode.train(3)
    Process.sleep(10000)

    CalculatorNode.send_model_via_ch(1, 2)
    CalculatorNode.send_model_via_ch(3, 2)
    CalculatorNode.send_model_via_ch(2, 1)
    Process.sleep(10000)
    IO.inspect(CalculatorNode.get_info(2))

  end
end
