defmodule Dataset do
  def download(:mnist) do
    Application.ensure_all_started(:inets)
    #file = [
    #  'train-images-idx3-ubyte.gz',
    #  'train-labels-idx1-ubyte.gz',
    #  't10k-images-idx3-ubyte.gz',
    #  't10k-labels-idx1-ubyte.gz'
    #]
    #File.mkdir_p("dataset/mnist")
    #Enum.each(file, fn f -> get_mnist(f) end)
    :ok
  end

  def get_mnist(file) do
    base_url = 'http://yann.lecun.com/exdb/mnist/'
    {:ok, resp} =
      :httpc.request(:get, {base_url ++ file, []}, [],
        body_format: :binary
      )

    {{_, 200, 'OK'}, _headers, body} = resp

    File.write!("dataset/mnist/#{file}", body)
    Mix.shell().cmd("gzip -d dataset/mnist/#{file}")
  end

  def train_label(:mnist) do
    {:ok, <<0, 0, 8, 1, 0, 0, 234, 96, label::binary>>} =
      File.read("dataset/mnist/train-labels-idx1-ubyte")
    label
  end

  def train_image(:mnist) do
    {:ok, <<0, 0, 8, 3, 0, 0, 234, 96, 0, 0, 0, 28, 0, 0, 0, 28, image::binary>>} =
      File.read("dataset/mnist/train-images-idx3-ubyte")
    image
  end

  def test_label(:mnist) do
    {:ok, <<0, 0, 8, 1, 0, 0, 39, 16, label::binary>>} = File.read("dataset/mnist/t10k-labels-idx1-ubyte")
    label
  end

  def test_image(:mnist) do
    {:ok, <<0, 0, 8, 3, 0, 0, 39, 16, 0, 0, 0, 28, 0, 0, 0, 28, image::binary>>} =
      File.read("dataset/mnist/t10k-images-idx3-ubyte")
    image
  end
end
