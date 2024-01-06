# D3FL Simulator [WIP]

## Overview

D3FL Simulator provides an environment to simulate Distributed Federated Learning, a form of federated learning that doesn't rely on servers for model aggregation. This simulation environment takes into account network quality metrics such as latency and packet loss.
By incorporating considerations for network quality metrics, this environment allows for a more realistic emulation of real-world scenarios and new algorithms in federated learning.

## Features

- **Decentralized Federated Learning Simulator:** Conduct Decentralized Federated Learning
- **Network Quality Simulation:** Consider network metrics such as latency and packet loss for a more accurate simulation.
- **Scalable and Customizable:** The simulator is designed to be scalable and allows customization of parameters for various simulation scenarios.

## Getting Started

### Installation

To set up and run the D3FL Simulator, follow these steps:

1. **Clone the Repository:**


2. **Install Dependencies:**
    - install [elixir](https://elixir-lang.org/install.html)
    - ```bash
      cd d3fl_simulator
      mix deps.get
      ```

3. **Run the Simulator Sample [WIP]:**
   - According to your federated learning algorithm, Please rewrite lib/d3fl_simulator/calculator_node/ai_core.ex and lib/mock_helper.ex
   - run the following code
    ```bash
    iex -S mix
    iex> MockHelper.start_mock()
    ```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `d3fl_simulator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:d3fl_simulator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/d3fl_simulator>.

