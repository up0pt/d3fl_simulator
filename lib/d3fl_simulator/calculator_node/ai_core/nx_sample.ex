defmodule NxSample do
  require Axon
  def train(former_model \\ %{}) do
    {images, labels} = Scidata.MNIST.download()

    {images_data, images_type, images_shape} = images

    images_tensor =
      images_data
      |> Nx.from_binary(images_type)
      |> Nx.reshape(images_shape)
      |> Nx.divide(255)
      |> Nx.reshape({60_000, :auto})

    {labels_data, labels_type, labels_shape} = labels

    labels_tensor =
      labels_data
      |> Nx.from_binary(labels_type)
      |> Nx.reshape(labels_shape)
      |> Nx.new_axis(-1)

    model =
    Axon.input("featurers", shape: {nil, 784})
    |> Axon.dense(128)
    |> Axon.relu()
    |> Axon.dense(10)
    |> Axon.softmax(name: "labels")


    images_train_data = Nx.to_batched(images_tensor, 32)
    labels_train_data = Nx.to_batched(labels_tensor, 32)

    train_data = Stream.zip(images_train_data, labels_train_data)
    train_data = Enum.map(train_data, fn {images_tensor, labels_tensor} ->
      {images_tensor, Nx.equal(labels_tensor, Nx.iota({10}))}
    end)

    trained_model_state
    = model
      |> Axon.Loop.trainer(:categorical_cross_entropy, :adam)
      |> Axon.Loop.run(train_data, former_model, compiler: EXLA, epochs: 1)

    {test_images, test_labels} = Scidata.MNIST.download_test()

    {t_images_data, t_images_type, t_images_shape} = test_images

    test_images_tensor =
      t_images_data
      |> Nx.from_binary(t_images_type)
      |> Nx.reshape(t_images_shape)
      |> Nx.divide(255)
      |> Nx.reshape({10_000, :auto})

    {t_labels_data, t_labels_type, t_labels_shape} = test_labels

    test_labels_tensor =
      t_labels_data
      |> Nx.from_binary(t_labels_type)
      |> Nx.reshape(t_labels_shape)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.iota({10}))

    images_test_data = Nx.to_batched(test_images_tensor, 32)
    labels_test_data = Nx.to_batched(test_labels_tensor, 32)
    test_data = Stream.zip(images_test_data, labels_test_data)

    evaluate =
      model
      |> Axon.Loop.evaluator()
      |> Axon.Loop.metric(:accuracy)
      |> Axon.Loop.run(test_data, trained_model_state, compiler: EXLA)


      %{
        0 => %{
          "accuracy" => accuracy
        }
      } = evaluate
      accuracy = Nx.to_number(accuracy)
   {trained_model_state, accuracy}
  end
end
