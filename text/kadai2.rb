  # 石を置き，ひっくり返す
  def move(x,y)
    if @movableDir[x][y] == NONE
      return false
    end

    #    self.flipDisks(x,y)
    @rawBoard[x][y] = @current_color
      
    @turns += 1
    @current_color = -1 * @current_color
    self.initMovable
      
    return true
  end
        
  # 「盤を描画して，手を入力をしてもらう」のを繰り返す（暫定テキスト版）
  def loop()
    while true do
      print(" abcdefgh\n")
         
      for y in 1..BOARDSIZE do
        for x in 1..BOARDSIZE do
          if x == 1
            s = "1".ord + y - 1
            print(s.chr("utf-8"))
          end
          if @rawBoard[x][y] == EMPTY
            print(" ")
          elsif @rawBoard[x][y] == BLACK
            print("x")
          elsif @rawBoard[x][y] == WHITE
            print("o")
          end
        end
        print("\n")
      end
      print("\n")
      
      print("次は")
      if @current_color == BLACK 
        print("黒")
      elsif
        print("白")
      end
      print("です．")
      
      # 入力された座標が正しいかどうかを表す変数
      isvalid = false
      
      # 正しい入力が得られるまで座標を入力してもらう
      while !isvalid do
        print("石を置く座標を入力してください（例：a1）-> ")
        input = gets.chomp
    
        if input.length == 2
          x = input[0].ord - "a".ord + 1
          y = input[1].ord - "1".ord + 1
    
          # もし入力された座標が石を打てる場所であれば，isvalid を true にする
          if x.between?(1,BOARDSIZE) and y.between?(1,BOARDSIZE) and @movableDir[x][y] != NONE
            isvalid = true
          end
        end

        if !isvalid
          print("そこには打てまへんで．知らんけど．\n")
        end
      end
      
      # 石を打ち，（ひっくり返して）手番を入れ替える．ただし今回は石を置くだけで，
      # ひっくり返すのは次回
      move(x,y)
    end
  end
