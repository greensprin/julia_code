module NN
  # package
  using Plots
  ## local
  include(".\\read_mnist.jl")
  using .myMnist

  # データ読み込み
  function readMnist(datapath)
    flatten_mode = 1
    normalize_mode = 1
    data_trn, data_tst = myMnist.readMnist(datapath, flatten_mode, normalize_mode)
    return data_trn, data_tst
  end

  # nodeの構造体
  mutable struct Node
    num     :: UInt32
    weight  :: Matrix{Float64}
    bias    :: Vector{Float64}
  end

  # NN初期化
  function NN_init(data_in, node_num)
    input_num = length(data_in[1].data)
    layer_num = length(node_num)
    node_ary = Array{Node}(undef, layer_num)

    for i in 1:layer_num
      row = (i == 1) ? input_num : node_num[i-1]
      col = node_num[i]
      weight  = randn(row, col)
      bias    = randn(1)
      node    = Node(UInt32(node_num[i]), weight, bias)

      node_ary[i] = node
    end

    return node_ary
  end

  # 活性化関数
  step_func(x) = (x > 0) ? 1 : 0 # Step関数
  sigmoid(x) = 1.0 / (1.0 + exp(-x)) # シグモイド関数
  relu(x) = max(x, 0) # Relu関数
  bypass(x) = x # スルー関数

  # 評価関数
  function softmax(data)
    data_max = maximum(data)
    data_exp = map(exp, (data .- data_max)) # inf対策のため最大値を引く
    data_exp_sum = sum(data_exp) # expの合計を計算
    return data_exp ./ data_exp_sum
  end

  # 誤差関数
  function mean_sq_err(data_ary, result)
    # 教師データ作成
    res_len = length(result)
    t = zeros(res_len)
    t[data_ary.label + 1] = 1.0 # julia配列は1~なので、+1する

    # 二乗和誤差計算
    return 0.5 * sum((result .- t) .^ 2)
  end

  # 中間層計算
  function CalLayer(data, node, eval_func)
    result = data * node.weight .+ node.bias
    return map(eval_func, result)
  end

  # ネットワーク設計
  function nn_forward(data_ary, node_ary)
    # 各層計算
    result = CalLayer(data_ary[1].data, node_ary[1], sigmoid)
    result = CalLayer(result, node_ary[2], sigmoid)
    result = CalLayer(result, node_ary[3], bypass)
    # 評価関数
    result = softmax(result)
    # 誤差計算
    err = mean_sq_err(data_ary[1], result)
    return result, err
  end

  # debug
  function debug(data_trn)
    num = UInt32(1) :: UInt32
    myMnist.showMnistImage(data_trn, num) # Mainをつける必要があるみたい
  end

  function showGraph(func, filename)
    gr()
    plot(func,
         xlabel = "X_value",
         ylabel = "Y_value",
         xlims  = (-5.0, 5.0),
         ylims  = (-0.1, 1.1),
    )
    savefig(filename)
  end
end

function main()
  # MNISTデータ読み込み
  datapath = ARGS[1]
  data_trn, data_tst = NN.readMnist(datapath)

  # NN初期化
  node_num = [5; 3; 10]
  node_ary = NN.NN_init(data_trn, node_num)

  # 順方向の処理
  result, err = NN.nn_forward(data_trn, node_ary)
  println(result)
  println(err)

  # 逆方向の処理（学習）

  # debug
  debug_out = 0
  if (debug_out == 1)
    # data
    NN.debug(data_trn)
    # 活性化関数
    NN.showGraph(NN.sigmoid, "sigmoid.png")
    NN.showGraph(NN.step_func, "step.png")
    NN.showGraph(NN.relu, "relu.png")
    # node_ary
    println(node_ary[2].num)
    println(size(node_ary[1].weight))
    println(node_ary[2].bias)
  end
end

if contains(@__FILE__, abspath(PROGRAM_FILE))
  main()
end