defmodule D3flSimulator.ComputerNode do
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

  def send_model(model, recv_node_index) do
    GenServer.cast(
      Utils.get_process_name(__MODULE__, recv_node_index),
      {:recv_model, model}
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

  def handle_call(:get_info, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:check_comm_avail, _from, %State{comm_available: comm_avail} = state) do
    {:reply, comm_avail, state}
  end

  def handle_cast({:recv_model, model}, _from, %State{recv_model_queue: queue} = state) do
    {:noreply, %State{state | recv_model_queue: :queue.in(model, queue)}}
  end
end
