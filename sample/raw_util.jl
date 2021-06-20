module RawBin
  # Rawデータ向け構造体(画サイズと画素値のみ)
  mutable struct Raw 
    width::Int16
    height::Int16
    pix::Array{Int16}
  end

  function read_bin(filename::String)::Raw
    # ファイルオープン
    f = open(filename, "r")

    # 画サイズ 取得
    width  = read(f, Int16)
    height = read(f, Int16)

    # 画素値取得
    pix = Array{Int16}(undef, height, width)
    read!(f, pix)

    # ファイルクローズ
    close(f)

    # 構造体宣言 (Raw)
    raw = Raw(width, height, pix)

    return raw
  end

  function write_bin(filename::String, raw::Raw)
    open(filename, "w") do f
      write(f, raw.width)
      write(f, raw.height)
      write(f, raw.pix)
    end
  end

  # 信号処理系の処理
  module ImageProcess
    import ..RawBin

    function doGain(raw::RawBin.Raw, gain)
      raw.pix = raw.pix .* gain
      return raw
    end

    function filter(raw::RawBin.Raw, kernel::Array{Int16})
      y_hf = div(size(kernel)[1], 2)
      x_hf = div(size(kernel)[2], 2)

      # フィルタ係数合計
      wgt = Base.sum(kernel)

      for y in 1:raw.height
        for x in 1:raw.width
          # 画像参照位置
          sta_y = clip(y - y_hf, 1, raw.height)
          end_y = clip(y + y_hf, 1, raw.height)
          sta_x = clip(x - x_hf, 1, raw.width)
          end_x = clip(x + x_hf, 1, raw.width)

          #println("$x, $y, $x_hf, $y_hf, $sta_x, $sta_y, $end_x, $end_y")

          # 係数乗算
          all_sum = Base.sum(raw.pix[sta_y:end_y, sta_x:end_x] .* kernel[1:(end_y - sta_y +1), 1:(end_x - sta_x +1)])

          # 結果計算 (rnd)
          raw.pix[y, x] = round(all_sum / wgt)
        end
      end

      return raw
    end

    function clip(val, min, max)
      tmp = 0
      if (val < min)
        tmp = min
      elseif (val > max)
        tmp = max
      else
        tmp = val
      end
      return tmp
    end
  end
end


function main()
  # 既存のファイルを読み込む
  raw = RawBin.read_bin("sample_write_binary.bin")
  println("width:  $(raw.width)")
  println("height: $(raw.height)")
  println("pix:    $(raw.pix)")

  # 新しいファイルとして書き込む
  RawBin.write_bin("write_bin_file.bin", raw)

  # 画素値にゲインをかける
  raw = RawBin.ImageProcess.doGain(raw, 2.0)
  println("pix:    $(raw.pix)")

  # フィルタをかける (3x3tap)
  kernel = Int16[1 1 1; 1 1 1; 1 1 1]
  raw = RawBin.ImageProcess.filter(raw, kernel)
  println("pix:    $(raw.pix)")
end

if contains(@__FILE__, abspath(PROGRAM_FILE))
  main()
end