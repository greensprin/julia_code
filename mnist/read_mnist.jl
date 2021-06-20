#=

  readMnist に対して、MNISTの各種ファイル（training, testのlabelとimage 計４ファイル）
  があるフォルダを与えてあげるとそれぞれ読み込んで構造体の配列としてreturnしてくれる

  ex) 
    datadirpath = "MNISTデータを格納しているフォルダパス"
    data_trn, data_tst = myMnist.readMnist(datadirpath)

    num: 1 <= num <= 60000(training) or 10000(test)
    data_trn[num].label # ラベル 1 UInt8
    data_trn[num].data  # 画像データ 28x28 UInt8 (正規化は行っていない)

  データセットのURL
  http://yann.lecun.com/exdb/mnist/

=#
module myMnist
  struct Data
    label :: UInt8
    data
  end

  function readLabelData(labelfile::String, datafile::String, flatten_mode, normalize_mode)
    # ファイルオープン
    fl = open(labelfile, "r")
    fd = open(datafile, "r")

    # データ読み込み
    # 識別子 (今回は不要)
    read(fl, Int32) # flg
    read(fd, Int32) # flg

    # 画像枚数
    l_num = bswap(read(fl, Int32))
    d_num = bswap(read(fd, Int32))
    if (l_num != d_num)
      println("label size and data size is not match.")
      exit()
    else
      println("data num is $l_num")
    end

    # サイズ
    height = bswap(read(fd, Int32)) # data height
    width  = bswap(read(fd, Int32)) # data width
    println("pix data size is $width x $height")

    # label / data 読み込み
    max_val = 255 # 8bitの最大
    data_ary = Array{Data}(undef, l_num)
    for num in 1:l_num
      # label
      label   = bswap(read(fl, UInt8))

      # data
      pix_val = (flatten_mode == 0) ? Array{UInt8}(undef, height, width) : Array{UInt8}(undef, height * width)
      read!(fd, pix_val)
      pix_val = map(bswap, pix_val) # little -> big (行列が反転して入っている。juliaでの配列の考え方がfortran由来であるからか？)

      if (normalize_mode == 0)
        pix_norm = pix_val
      else
        pix_norm = pix_val ./ max_val
      end

      # Data構造体作成
      data = Data(label, pix_norm') # pix_normは転置して入力 (行列が反転しているため)

      # 配列に追加
      data_ary[num] = data
    end

    # ファイルクローズ
    close(fl)
    close(fd)

    return data_ary
  end

  function readMnist(datapath::String, flatten_mode=0, normalize_mode=0)
    trn_dpath = joinpath(datapath, "train-images.idx3-ubyte")
    trn_lpath = joinpath(datapath, "train-labels.idx1-ubyte")
    tst_dpath = joinpath(datapath, "t10k-images.idx3-ubyte")
    tst_lpath = joinpath(datapath, "t10k-labels.idx1-ubyte")

    data_trn = readLabelData(trn_lpath, trn_dpath, flatten_mode, normalize_mode)
    data_tst = readLabelData(tst_lpath, tst_dpath, flatten_mode, normalize_mode)

    return data_trn, data_tst
  end

  # debug
  function showMnistImage(data, num::UInt32)
    println(data[num].label)

    height, width = size(data[num].data)
    for y in 1:height
      for x in 1:width
        val = data[num].data[y, x]

        flg = " "
        if (val > 128)
          flg = "■"
        end

        print("$flg ")
      end
      println("")
    end
  end
end

function main()
  # MNISTデータ読み込み
  datapath = ARGS[1]
  data_trn, data_tst = myMnist.readMnist(datapath)

  # debug
  num = UInt32(1) :: UInt32
  myMnist.showMnistImage(data_trn, num)
end

if contains(@__FILE__, abspath(PROGRAM_FILE))
  main()
end