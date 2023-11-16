defmodule D3flSimulator.Utils do
  @spec get_process_name(any(), any()) :: atom()
  def get_process_name(module, index) do
    :"#{module}_#{index}"
  end
end
