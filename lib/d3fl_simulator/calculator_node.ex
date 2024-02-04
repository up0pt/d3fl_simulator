defmodule D3flSimulator.CalculatorNode do
  require Logger
  use GenServer
  alias D3flSimulator.Utils
  alias D3flSimulator.Channel
  alias D3flSimulator.CalculatorNode.AiCore

  defmodule State do
    defstruct node_num: 0,
              data_dir_path: ""
  end

  defmodule SendDepend do
    defstruct send_time: nil,
              from: 0,
              to: 0,
              recv_time: nil,
              packetloss: 0
  end

  defmodule Tile do
    defstruct start_time: 0,
              end_time: 0,
              type: nil,
              func_args: nil,
              depend: nil
  end

  def start_link(args_tuple) do
    GenServer.start_link(
      __MODULE__,
      args_tuple
    )
  end

  def init(
    %{
      node_num: node_num,
      data_dir_path: data_dir_path
    }) do

    # children = [
    #   {AiCore, %{node_index: node_id}}
    # ]
    # opts = [strategy: :one_for_one]
    # {:ok, _id} = Supervisor.start_link(children, opts)

    # data_file_path = Path.join(data_dir_path, "CaluculatorNode_#{node_id}.csv")

    {:ok,
    %State{
      node_num: node_num,
      data_dir_path: data_dir_path
    }}
  end

  def start_exec(cn_send_learn_lists) do
    cn_send_learn_lists
    |> Flow.from_enumerable(max_demand: 1, stages: Enum.count(cn_send_learn_lists))
    |> Flow.map(
      fn cn_send_learn_list
      ->
        {node_id, init_model, send_learn_list} = cn_send_learn_list
        AiCore.start_link(node_id, init_model)
        exec_list(node_id, send_learn_list)
      end
      )
    |> Enum.to_list()
    |> IO.puts("simulation end")
  end

  def exec_list(node_id, [%Tile{} = head | tail] = send_learn_list) when is_list(send_learn_list)do
    %Tile{type: type} = head
    case type do
      :train ->
        train(node_id, head)
      :aggregate ->
        aggregate(node_id, head)
      :send ->
        send_model(node_id, head)
    end
    exec_list(node_id, tail)
  end

  def exec_list(node_id, []) do
    IO.puts("Node ID: #{node_id} end")
  end

  def train(node_id, send_learn_tile) do
    AiCore.train(node_id)
  end

  def aggregate(node_id, %Tile{depend: depend_list} = _send_learn_tile) do
    wait_for_depend(depend_list)
    AiCore.aggregate(node_id, depend_list)
  end

  def wait_for_depend([%SendDepend{} = head | tail] = depend_list) do
    case Process.whereis(Utils.channel_name(head)) do
      nil ->
        Process.sleep(500)
      pid when is_pid(pid) ->
        #TODO: get model from channel
        # pass to agg_mode_store(model)
        AiCore.agg_model_store()
        wait_for_depend(tail)
    end
  end

  def wait_for_depend(_) do
    nil
  end

  def send_model(_node_id, %Tile{} = send_learn_tile) do
    %Tile{} = send_learn_tile
    Channel.start_link()
  end


  # def handle_cast({:train, node_index},
  #                 %State{
  #                   model: former_model,
  #                   former_model_queue: fmodel_queue,
  #                   recv_model_queue: rmodel_queue,
  #                   eval_metrics_queue: eval_queue,
  #                   data_file_path: file_path
  #                   } = state) do
  #
  #   new_fmodel_queue = :queue.in(former_model, fmodel_queue)
  #   # aggregationの一例
  #   {{:value, recv_model}, rmodel_queue} = queue_out(rmodel_queue)
  #   base_model = AiCore.weighted_mean_model(former_model, recv_model, 1)
  #   # TODO: AiCore(weighted_mean_model) に rmodel_queue 全体を渡した方がいい．
  #   {new_model, metrics}= AiCore.train_model(node_index, base_model)
  #   new_eval_metrics_queue = :queue.in(metrics, eval_queue)
  #
  #   {:ok, fp} = File.open(file_path, [:append, :utf8])
  #   IO.write(fp, "#{new_wall_clock_time}, #{metrics}\n")
  #   File.close fp
  #
  #   {:reply,
  #    :ok,
  #    %State{
  #     state | model: new_model,
  #     former_model_queue: new_fmodel_queue,
  #     recv_model_queue: rmodel_queue,
  #     eval_metrics_queue: new_eval_metrics_queue},
  #   }
  # end
end
