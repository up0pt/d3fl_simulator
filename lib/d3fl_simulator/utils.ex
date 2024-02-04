defmodule D3flSimulator.Utils do
  alias D3flSimulator.CalculatorNode.SendDepend

  @spec get_process_name(any(), any()) :: atom()
  def get_process_name(module, index) do
    :"#{module}_#{index}"
  end

  def get_process_name_from_to(module, from_index, to_index) do
    :"#{module}_#{from_index}_#{to_index}"
  end

  def channel_name(%SendDepend{send_time: st, from: from, to: to, recv_time: rt}) do
    :"#{st}_#{from}_#{to}_#{rt}"
  end
end
