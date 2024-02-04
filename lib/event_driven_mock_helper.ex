defmodule EventDrivenMockHelper do
  alias D3flSimulator.Channel
  alias D3flSimulator.Channel.InputQoS
  alias D3flSimulator.CalculatorNode
  alias D3flSimulator.CalculatorNode.SendDepend
  alias D3flSimulator.CalculatorNode.Tile
  alias D3flSimulator.JobTilesExecutor
  alias D3flSimulator.JobTilesExecutor.JobTile
  alias D3flSimulator.Data



  def start_mock_2_CNs() do
    node_num = 2
    data_directory_path = MockHelper.prepare_data_directory!(node_num)

    cn1_send_learn = [
      %Tile{
        start_time: 0,
        end_time: 50,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 50,
        end_time: 100,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 100,
        end_time: 110,
        type: :send,
        func_args: %SendDepend{
          send_time: 100,
          recv_time: 110,
          from: 1,
          to: 2,
          packetloss: 0}
      },

      %Tile{
        start_time: 110,
        end_time: 130,
        type: :send,
        func_args: %SendDepend{
          send_time: 110,
          recv_time: 130,
          from: 1,
          to: 2,
          packetloss: 0}
      },

      %Tile{
        start_time: 120,
        end_time: 140,
        type: :send,
        func_args: %SendDepend{
          send_time: 120,
          recv_time: 140,
          from: 1,
          to: 2,
          packetloss: 0}
      },

      %Tile{
        start_time: 130,
        end_time: 150,
        type: :send,
        func_args: %SendDepend{
          send_time: 130,
          recv_time: 150,
          from: 1,
          to: 2,
          packetloss: 0}
      },

      %Tile{
        start_time: 100,
        end_time: 150,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 160,
        end_time: 180,
        type: :send,
        func_args: %SendDepend{
          send_time: 160,
          recv_time: 180,
          from: 1,
          to: 2,
          packetloss: 0}
      },

      %Tile{
        start_time: 150,
        end_time: 200,
        type: :train,
        func_args: nil,
        depend: nil
      }
    ]

    cn2_send_learn = [
      %Tile{
        start_time: 0,
        end_time: 50,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 50,
        end_time: 100,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 100,
        end_time: 150,
        type: :train,
        func_args: nil,
        depend: nil
      },

      %Tile{
        start_time: 150,
        end_time: 200,
        type: :aggregate,
        func_args: nil,
        depend: [
          %SendDepend{send_time: 100, from: 1, to: 2, recv_time: 110},
          %SendDepend{send_time: 110, from: 1, to: 2, recv_time: 130},
          %SendDepend{send_time: 120, from: 1, to: 2, recv_time: 140},
          %SendDepend{send_time: 130, from: 1, to: 2, recv_time: 150}
        ]
      }
    ]


  end
end
