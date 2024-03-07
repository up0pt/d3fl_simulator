# D3FL Simulator [WIP]

## Overview

D3-FL は，非中央集権型の連合学習（Decentralized Federated Learnin）のシミュレータです．
特長は４つあります．
- 通信品質の反映（レイテンシとパケットロス）
- スケーラビリティ（予定）
- 非同期な学習に対応
- availability（可用性，各デバイスが学習に使えるか否か）を設定可能（予定）

D3-FL Simulator provides an environment to simulate Decentralized Federated Learning, a form of federated learning that doesn't rely on servers for model aggregation. This simulation environment takes into account network quality metrics such as latency and packet loss.
By incorporating considerations for network quality metrics, this environment allows for a more realistic emulation of real-world scenarios and new algorithms in federated learning.

 Features

- **Decentralized Federated Learning Simulator:** Conduct Decentralized Federated Learning
- **Network Quality Simulation:** Consider network metrics such as latency and packet loss for a more accurate simulation.
- **Scalable and Customizable:** The simulator is designed to be scalable and allows customization of parameters for various simulation scenarios.

## Getting Started

### Installation

To set up and run the D3FL Simulator, follow these steps:

0. **Install Erlang and Elixir:**
    [公式の手順](https://elixir-lang.org/install.html)を参考にしてください．
    以下では，バージョン管理ツール asdf を用いて Erlang と Elixir をインストールしています．
    - Macの場合
      ```bash
      sudo apt update
      sudo apt install git curl git
      git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
      echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
      echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc
      source ~/.bashrc
      sudo apt -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

      asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
      asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
        
      asdf install erlang 26.0.2
      asdf install elixir 1.15.4-otp-26
      ```

2. **Clone this Repository:**

4. **Install Dependencies:**
   ```bash
      cd d3fl_simulator
      mix deps.get
   ```

5. **Run the Simulator Sample:**
   - According to your federated learning algorithm, Please rewrite lib/d3fl_simulator/calculator_node/ai_core.ex and lib/wc_mock_helper.ex
    - ai_core.ex：
      AICore モジュール内の関数 `model_aggregate/4, train_model/2` とそれらによって呼ばれる関数を変更してください．
      特に，`ai_core/nx_sample.ex` が学習部分のコードです．
    - wc_mock_helper.ex：
      `num_mock/1`を参考に，DFLを定義してください．
    
   - run the following code
   サンプルの場合`WcMockHelper.num_mock(5)`では5つの計算機ノード（学習参加者の計算機に対応するノード）を動作させます．モデルの交換は５つのノードが小さい順に横一列に並んだ時，隣同士のノード間で行われます．
   ```bash
   iex -S mix
   iex> WcMockHelper.num_mock(5)
   ```
   各ノードでの精度と wall-clock time （シミュレーション対象の時間．シミュレータの処理の所用時間ではない！）が `data/`にcsvファイルで保存されます．
   
   - (if necessary) run with [observer](https://www.erlang.org/doc/man/observer#start-0)
   シミュレータの計算資源の利用状況を知るために`observer`を利用する場合のコードが以下です．計測によってシミュレーションの所要時間が遅くなります．
   ```bash
   iex -S mix
   iex> :observer.start()
   iex> WcMockHelper.num_mock(5)
   ```
    
## ファイルの説明
### `lib/d3fl_simulator/calculator_node.ex`
- calculator_node は，計算機ノードを指します．これは，学習に参加する計算機（例えばスマホやサーバー，ラズパイなど）のことです．
- DFL における 訓練 と モデル交換 の送受信を行います．

### `lib/d3fl_simulator/channel.ex`
- channel は通信チャンネルを指します．これは，計算機ノード間の通信を抽象化したものです．
- 通信のパケットロスを反映します（現段階の実装では，レイテンシは次の`job_tiles_executor.ex`で反映しています． ）

### `lib/d3fl_simulator/job_tiles_executor.ex`
- job_tiles_executor は，各計算機ノードの 訓練 と モデル交換 のイベントを順に実行します．
- job_tiles_executor は計算機ノードごとに１つあります．

### `lib/wc_mock_helper.ex`
- ここで，DFLを実行する関数とそれの補助関数を記述しています．
