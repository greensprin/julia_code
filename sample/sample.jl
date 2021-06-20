struct Struct1
  x
  y
  z
end

function StSum(st1::Struct1)
  println(st1.x + st1.x)
end

function main()
  x = 1
  y = 2
  println(x + y)
  println(x * y)

  st1 = Struct1(1, 2, 3)
  println(st1)

  StSum(st1)

  #=
    配列
    juliaにおける配列は、列思考(fortran由来)とのことで、行思考のC, pythonなどとは異なるので注意
  =#
  ary = [1 2 3; 4 5 6]
  println(ary)

  for i in ary # 1, 4, 2, 5, 3, 6 の順番で表示される
    println(i)
  end

  for i in axes(ary, 1) # pythonっぽく表示される書き方
    println(ary[[i], :])
  end

  #=
    変数出力する際の便利なやり方 ($をつけることにより、文字列中に変数の値を入れることができる)
  =#
  println("x = $x")
end

if contains(@__FILE__, abspath(PROGRAM_FILE))
  main()
end