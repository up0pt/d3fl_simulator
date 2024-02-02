defmodule MockHelper do
  require Logger
  alias D3flSimulator.Data

  def prepare_data_directory!(node_counts) do
    data_directory_path =
      Application.get_env(:d3fl_simulator, :data_directory_path) ||
        raise """
        You have to configure :data_directory_path in config.exs
        ex) config :ping_pong_measurer_Zenohex, :data_directory_path, "path/to/directory"
        """

    dt_string = Data.datetime_to_string(DateTime.utc_now())
    directory_name = "date_#{dt_string}_CalculatorNodeNum_#{node_counts}"
    data_directory_path = Path.join(data_directory_path, directory_name)

    File.mkdir_p!(data_directory_path)
    data_directory_path
  end
end
