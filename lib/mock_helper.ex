defmodule MockHelper do
  require Logger

  alias D3flSimulator.ComputerNode

  @spec start_mock() :: :ok
  def start_mock() do
    ComputerNode.start_link({"a", "b", 1})
    ComputerNode.start_link({"c", "d", 2})


    ComputerNode.send_model(1, 2)
    ComputerNode.get_info(2)
  end
end
