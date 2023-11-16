defmodule D3flSimulator.CommChannelControl do
  use GenServer

  defmodule State do
    defstruct channels: []
  end

  defmodule Init_args do
    defstruct comp_nodes_num: 0
  end

  def start_link(args_tuple) do
    GenServer.start_link(
      __MODULE__,
      args_tuple,
      name: __MODULE__
    )
  end

  def init(%Init_args{comp_nodes_num: node_num}) do
    {:ok, %State{
      channels: Enum.to_list(0..node_num-1)
    }
    }
  end



end
