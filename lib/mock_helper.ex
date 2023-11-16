defmodule MockHelper do
  require Logger

  alias D3flSimulator.ComputerNode

  @spec start_mock() :: :ok
  def start_mock() do
    ComputerNode.start_link({"a", "b", 1})
    ComputerNode.get_info(1)
    Logger.info("sample")
  end
end
