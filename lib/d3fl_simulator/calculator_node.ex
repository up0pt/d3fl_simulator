defmodule D3flSimulator.CalculatorNode do
  require Logger
  use GenServer
  alias D3flSimulator.Utils
  alias D3flSimulator.Channel
  alias D3flSimulator.CalculatorNode.AiCore

  defmodule State do
    defstruct node_id: nil,
              model: %{},
              model_size: 0,
              model_train_time: 0,
              model_inference_time: 0,
              data: nil,
              comm_available: true,
              recv_model_queue: :queue.new,
              former_model_queue: :queue.new,
              eval_metrics_queue: :queue.new,
              data_file_path: ""
  end
  #TODO:  計算available, 測定などを足す

  def start_link(%{node_index: node_index} = args_tuple) do
    GenServer.start_link(
      __MODULE__,
      args_tuple,
      name: Utils.get_process_name(__MODULE__, node_index)
    )
  end

  def init(%{
    model: model,
    data: data,
    node_index: node_id,
    data_directory_path: data_dir_path
    }) do
    children = [
      {AiCore, %{node_index: node_id}}
    ]
    opts = [strategy: :one_for_one]
    {:ok, _id} = Supervisor.start_link(children, opts)

    data_file_path = Path.join(data_dir_path, "CaluculatorNode_#{node_id}.csv")

    {:ok,
    %State{
      node_id: node_id,
      model: model,
      data: data,
      data_file_path: data_file_path
    }}
  end

  def queue_out(queue) do
    case :queue.len(queue) do
      0 -> {{:value, %{}}, queue}
      _ -> :queue.out(queue)
    end
  end

  def check_comm_avail(recv_node_index) do
    comm_avail = GenServer.call(
      Utils.get_process_name(__MODULE__, recv_node_index),
      :check_comm_avail
    )
    comm_avail
  end

  def train(node_index, new_wall_clock_time) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      {:train, node_index, new_wall_clock_time},
      600_000
    )
    #TODO: change to GenServer.cast ?
    {:ok, nil}
  end

  def send_model(send_node_index, recv_node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, send_node_index),
      {:send_model, recv_node_index}
      )
  end

  @spec send_model_via_ch(integer(), integer()) :: :ok
  def send_model_via_ch(send_node_index, recv_node_index) do
    GenServer.call(
      # Utils.get_process_name_from_to("Channel", send_node_index, recv_node_index),
      Utils.get_process_name(__MODULE__, send_node_index),
      {:send_model_via_ch, recv_node_index}
    )
  end

  def recv_model(to_node_index, from_node_index, model) do
    # GenServer.call(
    #   Utils.get_process_name(__MODULE__,to_node_index),
    #   {:recv_model, from_node_index, model}
    # )
    GenServer.cast(
      Utils.get_process_name(__MODULE__,to_node_index),
      {:recv_model, from_node_index, model}
    )
  end

  def get_info(node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      {:get_info})
  end


  def handle_call({:get_info}, _from, %State{recv_model_queue: _recv_queue} = state) do
    {:reply, state, state}
  end

  def handle_call(:check_comm_avail, _from, %State{comm_available: comm_avail} = state) do
    {:reply, comm_avail, state}
  end

  # def handle_call({:recv_model, _from_node_index, model}, _from, %State{recv_model_queue: queue} = state) do
  #   # TODO: from_node_index と model を一緒に保持させる
  #   IO.puts("queue in model")
  #   new_queue = :queue.in(model, queue)
  #   {:reply, :ok, %State{state | recv_model_queue: new_queue}}
  # end

  def handle_call({:train, node_index, new_wall_clock_time},
                  _from,
                  %State{
                    model: former_model,
                    former_model_queue: fmodel_queue,
                    recv_model_queue: rmodel_queue,
                    eval_metrics_queue: eval_queue,
                    data_file_path: file_path
                    } = state) do

    new_fmodel_queue = :queue.in(former_model, fmodel_queue)
    # aggregationの一例
    {{:value, recv_model}, rmodel_queue} = queue_out(rmodel_queue)
    base_model = AiCore.weighted_mean_model(former_model, recv_model, 1)
    # TODO: AiCore(weighted_mean_model) に rmodel_queue 全体を渡した方がいい．
    {new_model, metrics}= AiCore.train_model(node_index, base_model)
    new_eval_metrics_queue = :queue.in(metrics, eval_queue)

    {:ok, fp} = File.open(file_path, [:append, :utf8])
    IO.write(fp, "#{new_wall_clock_time}, #{metrics}\n")
    File.close fp

    {:reply,
     :ok,
     %State{
      state | model: new_model,
      former_model_queue: new_fmodel_queue,
      recv_model_queue: rmodel_queue,
      eval_metrics_queue: new_eval_metrics_queue},
    }
  end

  def handle_call({:send_model_via_ch, recv_node_index},
                  _from,
                  %State{
                    model: sending_model,
                    node_id: send_node_index
                    } = state) do

    Channel.transfer_model(send_node_index, recv_node_index, sending_model)
    {:reply, :ok, state}
  end


  def handle_cast({:send_model, recv_node_index}, %State{model: sending_model, node_id: send_node_index} = state) do
    GenServer.cast(
      Utils.get_process_name(__MODULE__, recv_node_index),
      {:recv_model, send_node_index, sending_model}
      )
    {:noreply, state}
  end

  def handle_cast({:recv_model, _send_node_index, model}, %State{recv_model_queue: queue} = state) do
    # TODO: from_node_index と model を一緒に保持させる
    new_queue = :queue.in(model, queue)
    {:noreply, %State{state | recv_model_queue: new_queue}}
  end
end
