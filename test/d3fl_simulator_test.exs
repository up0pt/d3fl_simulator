defmodule D3flSimulatorTest do
  use ExUnit.Case
  doctest D3flSimulator

  test "agg timing" do
    assert 0 == 1
  end

  test "from send to recv" do
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
        type: :train,
        func_args: nil,
        depend: nil
      }

    ]

    cn2_learn = [
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
          %SendArgs{send_time: 100, from: 1, to: 2, recv_time: 110},
          %SendArgs{send_time: 110, from: 1, to: 2, recv_time: 130},
          %SendArgs{send_time: 120, from: 1, to: 2, recv_time: 140},
          %SendArgs{send_time: 130, from: 1, to: 2, recv_time: 150}
        ]
      }
    ]
  end
end
