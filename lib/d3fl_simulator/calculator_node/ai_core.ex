defmodule D3flSimulator.CalculatorNode.AiCore do
  use GenServer
  alias D3flSimulator.Utils

  defmodule State do
    defstruct node_id: nil,
              current_model: nil,
              models_for_agg: [],
              metadata_for_agg: []
  end

  def start_link(%{node_id: node_id} = arg_map) do
    GenServer.start_link(
      __MODULE__,
      arg_map,
      name: Utils.get_process_name(__MODULE__, node_id)
    )
  end

  def init(%{node_index: node_id, init_model: model}) do
    {:ok,
    %State{
      node_id: node_id,
      current_model: model
    }}
  end

  def aggregate(node_id) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_id),
      {:aggregate},
      :infinity
    )
  end

  # def train_model(node_id, former_model) do
  #   GenServer.call(
  #     Utils.get_process_name(__MODULE__, node_id),
  #     {:train, former_model},
  #     :infinity
  #   )
  # end

  # def weighted_mean_model(map_a, nil, _) do
  #   map_a
  # end

  # def weighted_mean_model(nil, map_b, _) do
  #   map_b
  # end

  # def weighted_mean_model(map_a, %{}, _) do
  #   map_a
  # end

  # def weighted_mean_model(%{}, map_b, _) do
  #   map_b
  # end

  # # the above codes would make a bug (when both map_a & map_b are nil)

  # def weighted_mean_model(map_a, map_b, rate_b) do
  #   keys = Map.keys(map_a)
  #   result_map = %{}
  #   [result_map] = Enum.map(keys, fn key ->
  #     value_a = Map.get(map_a, key)
  #     v_a_bias = Map.get(value_a, "bias")
  #     v_a_kernel = Map.get(value_a, "kernel")

  #     value_b = Map.get(map_b, key)
  #     v_b_bias = Map.get(value_b, "bias")
  #     v_b_kernel = Map.get(value_b, "kernel")

  #     result_map = Map.put(
  #       result_map,
  #       key,
  #       %{"bias" => Nx.multiply(v_b_bias, rate_b)
  #                   |> Nx.add(v_a_bias)
  #                   |> Nx.divide(1 + rate_b),
  #         "kernel" => Nx.multiply(v_b_kernel, rate_b)
  #                   |> Nx.add(v_a_kernel)
  #                   |> Nx.divide(1 + rate_b)}
  #     )
  #     result_map
  #   end)
  #   result_map
  # end

  def agg_model(former_model, [head | tail] = model_list, tmp_model) do
    weighted_mean_model(former_model)
  end

  def agg_model(_, [], model) do
    model
  end

  def agg_model_store(to_node_id, model) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, to_node_id),
      {:model_store, model},
      :infinity
    )
  end

  def handle_call({:model_store, model}, _from, %State{models_for_agg: models_list} = state) do
    #TODO: need Lock to add list concurrently?
    models_list = [model | models_list]
    {:reply, nil, %State{state | models_for_agg: models_list}}
  end

  def handle_call(:aggregate,
                  _from,
                  %State{
                    current_model: former_model,
                    models_for_agg: model_list,
                    metadata_for_agg: _meatdata_list
                  } = state)  do
    model = agg_model(former_model, new_model, rate)
    {:reply, model, state}
  end

  # def handle_call({:train, former_model},
  #                 _from,
  #                 state) do
  #   model = NxSample.train(former_model)
  #   {:reply, model, state}
  # end

end
