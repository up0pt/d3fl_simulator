defmodule D3flSimulator.Utils do
  @spec get_process_name(any(), any()) :: atom()
  def get_process_name(module, index) do
    :"#{module}_#{index}"
  end

  def get_process_name_from_to(module, from_index, to_index) do
    :"#{module}_#{from_index}_#{to_index}"
  end
end
