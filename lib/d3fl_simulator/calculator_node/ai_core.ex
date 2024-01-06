defmodule D3flSimulator.CalculatorNode.AiCore do
  def train_model(former_model) do
    NxSample.train(former_model)
  end

  def weighted_mean_model(map_a, nil, _) do
    map_a
  end

  def weighted_mean_model(nil, map_b, _) do
    map_b
  end

  def weighted_mean_model(map_a, %{}, _) do
    map_a
  end

  def weighted_mean_model(%{}, map_b, _) do
    map_b
  end

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
