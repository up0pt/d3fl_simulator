defmodule D3flSimulator.ComputerNode do
  require Logger
  use GenServer
  alias D3flSimulator.Utils

  defmodule State do
    defstruct node_id: nil,
              model: nil,
              data: nil,
              comm_available: true,
              recv_model_queue: :queue.new
  end
  #TODO:  計算available, 測定などを足す

  def start_link({_, _, node_index} = args_tuple) do
    GenServer.start_link(
      __MODULE__,
      args_tuple,
      name: Utils.get_process_name(__MODULE__, node_index)
    )
  end

  def init({model, data, node_id}) do
    {:ok,
    %State{
      node_id: node_id,
      model: model,
      data: data
    }}
  end

  def check_comm_avail(recv_node_index) do
    comm_avail = GenServer.call(
      Utils.get_process_name(__MODULE__, recv_node_index),
      :check_comm_avail
    )
    comm_avail
  end

  def send_model(send_node_index, recv_node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, send_node_index),
      {:send_model, recv_node_index}
      )
  end

  def recv_model(_model) do
    # do nothing
  end

  def get_info(node_index) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, node_index),
      :get_info)
  end

  def handle_call(:get_info, _from, %State{recv_model_queue: recv_queue} = state) do
    {{_, value}, _} = :queue.out(recv_queue)
    Logger.info(value)
    {:reply, state, state}
  end

  def handle_call(:check_comm_avail, _from, %State{comm_available: comm_avail} = state) do
    {:reply, comm_avail, state}
  end

  def handle_call({:send_model, recv_node_index}, _from, %State{model: sending_model, node_id: send_node_index} = state) do
    GenServer.call(
      Utils.get_process_name(__MODULE__, recv_node_index),
      {:recv_model, send_node_index, sending_model}
      )
    {:reply, state, state}
  end

  def handle_call({:recv_model, _send_node_index, model}, _from,  %State{recv_model_queue: queue} = state) do
    queue = :queue.in(model, queue)
    {:reply, state, %State{state | recv_model_queue: queue}}
  end
end
