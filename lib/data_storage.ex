defmodule DataStorage do
  use Agent

  def start_link(initial_data) do
    Agent.start_link(fn -> initial_data end, name: __MODULE__)
  end

  def get_data() do
    Agent.get(__MODULE__, & &1)
  end

  def set_data(data) do
    Agent.update(__MODULE__, fn _ -> data end)
  end
end
