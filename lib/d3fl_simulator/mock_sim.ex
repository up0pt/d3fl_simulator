defmodule D3flSimulator.MockSim do

  # ネットワーク経由で計算機ノード同士がやりとりするデータ
  defmodule CommunicationData do
    defstruct model_info: [],
              sender_role: "",
              receiver_role: "",
              evaluate_metrics: "",
              communication_round: 0
  end

  # 計算機ノードが通信・チャンネル管理に与える通信状態データ
  defmodule ComputerNodeCommState do
    @lnum 1000
    defstruct comm_available: false,
              node_up_bandwidth: @lnum,
              node_down_bandwidth: @lnum
  end

  # ネットワーク
  defmodule Network do

  end

  # 通信・チャネル管理
  defmodule CommunicationControl do
    defmodule ChannelControl do
      defstruct channel_list: [],
                waiting_sender_list: [],
                available_node_list: []
    end

  end

  # ネットワーク品質
  defmodule NetworkQuality do
    @lnum 1000
    defstruct uptime: @lnum,
              jitter: [],
              latency: 0,
              maxbandwidth: @lnum,
              packetloss: 0,
              packetreptition: 0,
              QoS: [],
              protocol: ""
  end



end
