defmodule D3flSimulator.CalculatorNode.AiCore do
  use GenServer
  alias D3flSimulator.Utils

  defmodule State do
    defstruct node_id: nil,
              calc_available: true
  end

  def start_link(%{node_index: node_id} = arg_map) do
    GenServer.start_link(
      __MODULE__,
      arg_map,
      name: Utils.get_process_name(__MODULE__, node_id)
    )
  end

  def init(%{node_index: node_id} = _arg_map) do
    {:ok,
    %State{
      node_id: node_id
    }}
  end

  def train_model(former_model) do
    NxSample.train(former_model)
  end

  def weighted_mean_model(map_a, map_b, _)
      when map_a == nil and map_b == nil,
      do: %{}

  def weighted_mean_model(map_a, map_b, _)
      when map_b == nil or map_b == %{},
      do: map_a

  def weighted_mean_model(map_a, map_b, _)
      when map_a == nil or map_a == %{},
      do: map_b

  def weighted_mean_model(map_a, map_b, rate_b) do
    keys = Map.keys(map_a)
    result_map = %{}
    [result_map] = Enum.map(keys, fn key ->
      value_a = Map.get(map_a, key)
      v_a_bias = Map.get(value_a, "bias")
      v_a_kernel = Map.get(value_a, "kernel")

      value_b = Map.get(map_b, key)
      v_b_bias = Map.get(value_b, "bias")
      v_b_kernel = Map.get(value_b, "kernel")

      result_map = Map.put(
        result_map,
        key,
        %{"bias" => Nx.multiply(v_b_bias, rate_b)
                    |> Nx.add(v_a_bias)
                    |> Nx.divide(1 + rate_b),
          "kernel" => Nx.multiply(v_b_kernel, rate_b)
                    |> Nx.add(v_a_kernel)
                    |> Nx.divide(1 + rate_b)}
      )
      result_map
    end)
    result_map
  end
end
