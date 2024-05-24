defmodule MNISTDataLoader do
  @train_images_path "dataset/mnist/train-images-idx3-ubyte"
  @train_labels_path "dataset/mnist/train-labels-idx1-ubyte"
  @test_images_path "dataset/mnist/t10k-images-idx3-ubyte"
  @test_labels_path "dataset/mnist/t10k-labels-idx1-ubyte"

  def load_data do
    train_images = load_images(@train_images_path)
    train_labels = load_labels(@train_labels_path)
    test_images = load_images(@test_images_path)
    test_labels = load_labels(@test_labels_path)
    {train_images, train_labels, test_images, test_labels}
  end

  defp load_images(file_path) do
    {:ok, binary} = File.read(file_path)
    <<_magic::32, num_images::32, rows::32, cols::32, rest::binary>> = binary
    images = for <<image::binary-size(rows * cols) <- rest>>, do: :binary.bin_to_list(image)
    images
  end

  defp load_labels(file_path) do
    {:ok, binary} = File.read(file_path)
    <<_magic::32, num_labels::32, rest::binary>> = binary
    labels = :binary.bin_to_list(rest)
    labels
  end
end
