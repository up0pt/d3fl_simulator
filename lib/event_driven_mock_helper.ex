defmodule EventDrivenMockHelper do
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS
  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.JobTilesExecutor
  alias D3flSimulator.JobTilesExecutor.JobTile
  alias D3flSimulator.Data

  def send_to_recv() do

  end

  def start_mock_2_CNs() do
    node_num = 2
    data_directory_path = MockHelper.prepare_data_directory!(node_num)
    cn1_send = [
      %{send_time: 100, from: 1, to: 2, recv_time: 110, packetloss: 0},
      %{send_time: 110, from: 1, to: 2, recv_time: 130, packetloss: 0},
      %{send_time: 120, from: 1, to: 2, recv_time: 140, packetloss: 0},
      %{send_time: 130, from: 1, to: 2, recv_time: 150, packetloss: 0},
      %{send_time: 160, from: 1, to: 2, recv_time: 170, packetloss: 0}
    ]

    cn2_send = []

    cn1_recv = []

    cn2_recv = [
      %{send_time: 100, from: 1, recv_time: 110},
      %{send_time: 110, from: 1, recv_time: 130},
      %{send_time: 120, from: 1, recv_time: 140},
      %{send_time: 130, from: 1, recv_time: 150},
      %{send_time: 160, from: 1, recv_time: 170}
    ]

    cn1_learn = [
      %{
        start_time: 0,
        end_time: 50,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: 50,
        end_time: 100,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: 100,
        end_time: 150,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: 150,
        end_time: 200,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      }

    ]

    cn2_learn = [
      %{
        start_time: 0,
        end_time: 50,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 50,
        end_time: 100,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 100,
        end_time: 150,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 150,
        end_time: 200,
        type: :aggregate,
        func: fn -> CalculatorNode.aggregate(node_id = 2) end,
        depend: [
          %{send_time: 100, from: 1, to: 2, recv_time: 110},
          %{send_time: 110, from: 1, to: 2, recv_time: 130},
          %{send_time: 120, from: 1, to: 2, recv_time: 140},
          %{send_time: 130, from: 1, to: 2, recv_time: 150}
        ]
      }
    ]


    cn1_send_learn = [
      %{
        start_time: 0,
        end_time: 50,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: 50,
        end_time: 100,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: nil,
        end_time: nil,
        type: :send,
        func: fn -> Channel.transfer(1, 2, packetloss: 0) end
      },

      %{
        start_time: nil,
        end_time: nil,
        type: :send,
        func: fn -> Channel.transfer(1, 2, packetloss: 0) end
      },

      %{
        start_time: nil,
        end_time: nil,
        type: :send,
        func: fn -> Channel.transfer(1, 2, packetloss: 0) end
      },

      %{
        start_time: nil,
        end_time: nil,
        type: :send,
        func: fn -> Channel.transfer(1, 2, packetloss: 0) end
      },

      %{
        start_time: 100,
        end_time: 150,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      },

      %{
        start_time: nil,
        end_time: nil,
        type: :send,
        func: fn -> Channel.transfer(1, 2, packetloss: 0) end
      },

      %{
        start_time: 150,
        end_time: 200,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 1) end,
        depend: nil
      }
    ]

    cn2_send_learn = [
      %{
        start_time: 0,
        end_time: 50,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 50,
        end_time: 100,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 100,
        end_time: 150,
        type: :train,
        func: fn -> CalculatorNode.train(node_id = 2) end,
        depend: nil
      },

      %{
        start_time: 150,
        end_time: 200,
        type: :aggregate,
        func: fn -> CalculatorNode.aggregate(node_id = 2) end,
        depend: [
          %{send_time: 100, from: 1, to: 2, recv_time: 110},
          %{send_time: 110, from: 1, to: 2, recv_time: 130},
          %{send_time: 120, from: 1, to: 2, recv_time: 140},
          %{send_time: 130, from: 1, to: 2, recv_time: 150}
        ]
      }
    ]
  end
end
