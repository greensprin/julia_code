using Base: func_for_method_checked

function sample_1()
  println("Hello, World.")
  x = 1
  println("x = $x") # 変数を文字列中に入れるやり方
end

function sample_2()
  x = 10
  y = 20

  println(x + y) # 加算
  println(x - y) # 減算
  println(x * y) # 乗算
  println(x / y) # 除算
  println(div(x, y)) # 商
  println(x % y) # 余
  println(rem(x, y)) # 余
  println(x ^ 2) # 累乗
end

function sample_3()
  number = Base.prompt("input number: ")
  println("your number is $number")
  number_mul3 = parse(Int, number) * 3
  println("mul 3 is $number_mul3")
end

function sample_4()
  # 絶対値
  x = -10
  x_abs = abs(x)
  println("$x - abs -> $x_abs")
end

function sample_5()
  # シンプルなfor分
  for i in 0:15 # 15まで処理される(閉区間)
    println(i)
  end

  # 逆順
  println("逆順")
  for i in reverse(0:15) # 15から処理される(閉区間)
    println(i)
  end
end

function sample_6()
  x = parse(Int, Base.prompt("input number"))
  if (x <= 20 && x >= 5)
    println("OK.")
  elseif (x < 5 || x > 20)
    println("No.")
  end
end

function sample_7()
  test_chr = 't'
  println("single quotation is char: $test_chr")
  println(typeof(test_chr))

  test_str = "test"
  println("double quotation is string: $test_str") # Stringは、charの配列ではないので注意
  println(typeof(test_str))

  # 文字列の長さ
  println(length(test_str))

  # 文字列の結合 「*」で結合するので注意
  println(test_str * "_added_string")
end

function sample_8()
  #=
    参考サイト
    配列操作: https://qiita.com/A03ki/items/007be353411d19952ef7
    行列演算: https://qiita.com/haru1843/items/3956dab2fd0d448cd02b
  =#

  # 1次元配列
  one_dir_ary = [1, 2, 3, 4, 5]
  println(one_dir_ary)

  # 2次元配列
  two_dir_ary = [1 2 3; 4 5 6]
  println(two_dir_ary)

  # for での扱い (列から取得される)
  for e in two_dir_ary
    println(e)
  end

  # forで行から読みだす方法
  for e in axes(two_dir_ary, 1)
    println(two_dir_ary[e, :])
  end

  # １つずつ取り出す場合 (普通にfor分使ってもC言語と比較しても早いのか？)
  for y in 1:2
    for x in 1:3
      # println("$x, $y")
      cur_num = two_dir_ary[y, x]
      print("$cur_num ")
    end
    println()
  end

  # zeros (すべての要素を0で埋めた任意の大きさの配列)
  smp_zeros = zeros(2, 3)
  println(smp_zeros)

  # 内包表記
  smp_naiho = [x for x in 1:5]
  println(smp_naiho)
  smp_naiho = [x for x in 1:5 if (x%2) == 0] # 条件を追加することで、偶数だけを取り出すこともできる
  println(smp_naiho)
  smp_naiho = [a*b for a in 1:2 , b in 3:4] # 二次元配列を作ることでもできる
  println(smp_naiho)

  # 行列演算
  # 単純な乗算
  a = [ 1 2; 3 4 ]
  b = [ 1 2; 3 4 ]
  println(a .* b) # ドット「.」をつけると、各要素に対して関数を適用できる
  println(sin.(a)) # sinだけでなく、任意の関数を適用できる
  println(a ./ b) # 要素ごとの除算

  # 行列の乗算
  println(a * b) # .をつけなかった場合、行列の乗算が行われる

  # 行列の除算 (逆行列との乗算)
  println(inv(b)) # 逆行列
  println(a / b) # a * inv(b) を表す
  
  # 転置行列
  println(a') # 複素数を扱っている場合は, transpose()を使うようにする. 複素数に対して'をつける、エルミート行列が求まる

  # 配列のコピー
  c = a # 浅いコピー
  c .= 0
  println(a) # all 0になる

  c = copy(b) # 深いコピー
  c .= 0
  println(b) # all 0にならない

end

# moduleを定義すると、ほかのファイルでusingを使うことで呼び出せるようになる
# using .smp_mod_9
module smp_mod_9()
  a = 3.0
  function mod_9_func(x)
    b = x + 1
    println("b = $b")
    return b
  end

  struct Dog
    name::String
    age::Int64
  end

  struct Cat
    name::String
    age::Int64
  end

  function AnimalBeep(animal::Dog)
    println("Wan, Wan")
  end

  function AnimalBeep(animal::Cat)
    println("Nyaa, Nyaa")
  end
end

function sample_10()
  #=

    open ("filename", "r or w or a") do f
    end
    # closeを行わなくてよいので、安全だが、変数のスコープがこの中だけになってしまう

    f = open("filename", "r or w or a")
    close(f)
    # closeを行わないといけないが、変数スコープが限られない

  =#
  # 通常の読み込み
  open("sample_read.txt", "r") do f
    cnt = 0
    #for line in readlines(f) # pythonのようにこちらでもOK
    for line in eachline(f) # juliaではeachlineと書いてあるサンプルのほうが多かった
      println("$cnt 行目 $line")
      cnt += 1
    end
  end

  # バイナリファイル読み込み
  open("sample_write_binary.bin", "r") do f
    width  = read(f, Int16) # 16bit読み込む
    height = read(f, Int16)
    println("$width, $height")

    # 配列の読み込み
    raw = Array{Int16}(undef, height, width)
    read(f, raw)

    println(raw)
  end

  # 書き込み
  open("sample_write.txt", "w") do f
    println(f, "サンプルの書き込みです")
    println(f, "printlnで書き込めるのは便利")
    write(f, "writeでは改行が入らないので、必要ならいつものやつを入れる")
  end

  # バイナリファイル書き込み
  open("sample_write_binary.bin", "w") do f
    write(f, Int16(3)) # 16bitで書き込む
    write(f, Int16(2))

    # 配列の書き込み
    x = Int16[1 2 3; 4 5 6]
    write(f, x)
  end
end

function main()
  # sample 0 (コマンドライン引数)
  # println(ARGS)
  flg = parse(Int, ARGS[1]) # parse キャストするときに使う (重要！！)
  println("execute sample $flg")
  
  if flg == 1
    println("sample 1 (文字列を出力する)")
    sample_1()
  elseif flg == 2
    println("sample 2 (四則演算)")
    sample_2()
  elseif flg == 3
    println("sample 3 (キーボード入力)")
    sample_3()
  elseif flg == 4
    println("sample 4 (数学的な内容)")
    sample_4()
  elseif flg == 5
    println("sample 5 (for)")
    sample_5()
  elseif flg == 6
    println("sample 6 (論理式(AND))")
    sample_6()
  elseif flg == 7
    println("sample 7 (文字列操作)")
    sample_7()
  elseif flg == 8
    println("sample 8 (配列, 行列演算)")
    sample_8()
  elseif flg == 9
    println("sample 9 (構造体)")

    #=
      モジュールで一つの集合を作る
      構造体でデータの塊を作る
      多重ディスパッチで、構造体に必要な関数を生成する
      こうすることで、クラスではないが、１つのデータや処理の塊ができるので、考えやすくなるのか？
    =#

    # モジュール
    println(smp_mod_9.a)
    println(smp_mod_9.mod_9_func(3))

    # 構造体
    dog = smp_mod_9.Dog("Pochi", 16)
    cat = smp_mod_9.Cat("Mike" , 17)
    println(dog, cat)

    # 多重ディスパッチ
    smp_mod_9.AnimalBeep(dog)
    smp_mod_9.AnimalBeep(cat)
  elseif flg == 10
    println("sample 10 (ファイル読み込み)")
    sample_10()
  else
    print("your input sample num is not found.")
  end

end

if contains(@__FILE__, abspath(PROGRAM_FILE))
  main()
end