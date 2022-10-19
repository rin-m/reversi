# coding: utf-8

# 盤に配置する石，壁，空白
BLACK = 1
WHITE = -1
EMPTY = 0
WALL = 2
	
# 石を打てる方向（２進数のビットフラグ）
NONE = 0
UPPER = 1
UPPER_LEFT = 2
LEFT = 4
LOWER_LEFT = 8
LOWER = 16
LOWER_RIGHT = 32
RIGHT = 64
UPPER_RIGHT = 128

# 盤のサイズと手数の最大数
BOARDSIZE = 8
MAXTURNS = 60
	
# 盤を表すクラスの定義
class Board
	
  # 盤を表す配列
  @rawBoard = nil
  # 石を打てる場所を格納する配列
  @movableDir = nil
	
  # 盤を（再）初期化
  def init
    @turns = 0
    @current_color = BLACK
    
    # 配列が未作成であれば作成する
    if @rawBoard == nil
      @rawBoard = Array.new(BOARDSIZE + 2).map{Array.new(BOARDSIZE + 2,EMPTY)}
    end
    if @movebleDir == nil
      @movableDir = Array.new(BOARDSIZE + 2).map{Array.new(BOARDSIZE + 2,NONE)}
    end
  
    # @rawBoardを初期化，周囲を壁(WALL)で囲む
    for x in 0..BOARDSIZE + 1 do
      for y in 0..BOARDSIZE + 1 do
        @rawBoard[x][y] = EMPTY
        if y == 0 or y == BOARDSIZE + 1 or x == 0 or x == BOARDSIZE + 1
	  @rawBoard[x][y] = WALL
        end
      end
    end
	
    # 石を配置
    @rawBoard[4][4] = WHITE
    @rawBoard[5][5] = WHITE
    @rawBoard[4][5] = BLACK
    @rawBoard[5][4] = BLACK

    self.initMovable
  end

  # ここに initMovableとcheckmobilityの定義を追加
  def initMovable
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        dir = self.checkMobility(x,y,@current_color)
        @movableDir[x][y] = dir
      end
    end
  end
  
  # 石を打てる方向を調べる
  def checkMobility(x1,y1,color)
    # 石が置いてあれば打てない
    if @rawBoard[x1][y1] != EMPTY
      return NONE
    end

    # 打てる方向dirを初期化
    dir = NONE

    # 上
    x = x1
    y = y1
    if @rawBoard[x][y-1] == -color
      y = y - 1
      while (@rawBoard[x][y] == -color)
        y = y - 1
      end
      if @rawBoard[x][y] == color
        dir |= UPPER
      end
    end

    # 下
    x = x1
    y = y1
    if @rawBoard[x][y+1] == -color
      y = y + 1
      while (@rawBoard[x][y] == -color)
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER
      end
    end

    # 左
    x = x1
    y = y1
    if @rawBoard[x-1][y] == -color
      x = x - 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
      end
      if @rawBoard[x][y] == color
        dir |= LEFT
      end
    end

    # 右
    x = x1
    y = y1
    if @rawBoard[x+1][y] == -color
      x = x + 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
      end
      if @rawBoard[x][y] == color
        dir |= RIGHT
      end
    end

    # 以下同様に，右上(UPPER_RIGHT)，左上(UPPER_LEFT)，左下(LOWER_LEFT)，
    # 右下(LOWER_RIGHT) の判定を行うコードを書く
    # 右上
    x = x1
    y = y1
    if @rawBoard[x+1][y-1] == -color
      x = x + 1
      y = y - 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
        y = y - 1
      end
      if @rawBoard[x][y] == color
        dir |= UPPER_RIGHT
      end
    end

    # 左上
    x = x1
    y = y1
    if @rawBoard[x-1][y-1] == -color
      x = x - 1
      y = y - 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
        y = y - 1
      end
      if @rawBoard[x][y] == color
        dir |= UPPER_LEFT
      end
    end

    # 左下
    x = x1
    y = y1
    if @rawBoard[x-1][y+1] == -color
      x = x - 1
      y = y + 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER_LEFT
      end
    end

    # 右下
    x = x1
    y = y1
    if @rawBoard[x+1][y+1] == -color
      x = x + 1
      y = y + 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER_RIGHT
      end
    end

    return dir
  end

  def flipDisks(x1, y1)
    dir = @movableDir[x1][y1]
    @rawBoard[x1][y1] = @current_color

    # 上
    x = x1
    y = y1
    if (dir & UPPER) != NONE
      while @rawBoard[x][y-1] != @current_color
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 下
    x = x1
    y = y1
    if (dir & LOWER) != NONE
      while @rawBoard[x][y+1] != @current_color
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左
    x = x1
    y = y1
    if (dir & LEFT) != NONE
      while @rawBoard[x-1][y] != @current_color
        x = x - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x+1][y] != @current_color
        x = x + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右上
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x+1][y-1] != @current_color
        x = x + 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左上
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x-1][y-1] != @current_color
        x = x - 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左下
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x-1][y+1] != @current_color
        x = x - 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右下
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x+1][y+1] != @current_color
        x = x + 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end

  # ここに move と loop の定義を追加
  # 石を置き，ひっくり返す
  def move(x,y)
    if @movableDir[x][y] == NONE
      return false
    end

    self.flipDisks(x,y)
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

end

# Boardインスタンスの生成
board = Board.new

# 盤を初期化
board.init
# loopの実行（コメントは後で外す）
board.loop
