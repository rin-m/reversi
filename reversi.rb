# coding: utf-8

require "tk"

# マス（盤の1区画）の幅
SWIDTH = 70
# 盤の周囲マージン（座標の数字を書くスペース）
MARGIN = 20
# メッセ―ジの表示領域の高さ（盤の下の空白領域）
MHEIGHT = 80

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

# minmaxで探索する深さ（先を読む手数）
LIMIT = 5
# 残り手数がLIMIT2以下になったら最後まで読み切る
LIMIT2 = 10
# スコアの最大値
MAXSCORE = 10000

# ボタンの表示領域の高さ
BHEIGHT = 25
	
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
    if (dir & UPPER_RIGHT) != NONE
      while @rawBoard[x+1][y-1] != @current_color
        x = x + 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左上
    x = x1
    y = y1
    if (dir & UPPER_LEFT) != NONE
      while @rawBoard[x-1][y-1] != @current_color
        x = x - 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左下
    x = x1
    y = y1
    if (dir & LOWER_LEFT) != NONE
      while @rawBoard[x-1][y+1] != @current_color
        x = x - 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右下
    x = x1
    y = y1
    if (dir & LOWER_RIGHT) != NONE
      while @rawBoard[x+1][y+1] != @current_color
        x = x + 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end
  end

  def isGameOver
    # 60手に達していたら終了
    if @turn == MAXTURNS
      return true
    end

    # 現在の手番(@current_color)で打てる場所があればfalseを返す
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        if @movableDir[x][y] != NONE
          return false
        end
      end
    end

    # 自分がパスした場合、相手に打てる手があればfalseを返す
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        if checkMobility(x, y, -@current_color) != NONE
          return false
        end
      end
    end

    # 以上に当てはまらなければゲーム終了、trueを返す
    return true
  end

  def isPass
    # 現在の手番で打てる手があればfalseを返す
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        if @movableDir[x][y] != NONE
          return false
        end
      end
    end

    # 相手の手番で打てる手があればtureを返す
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        if checkMobility(x, y, -@current_color) != NONE
          return true
        end
      end
    end
    
    # 相手も打てなければfalseを返す
    return false
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

  def makeWindow
    # 盤の幅と高さ
    w = SWIDTH * 8 + MARGIN * 2
    h = SWIDTH * 8 + MARGIN * 2

    # ルートウィンドウ
    top = TkRoot.new(title: 'Othello', width: w, height: h + MHEIGHT + BHEIGHT)

    # 盤を描くためのキャンバス
    canvas = TkCanvas.new(top, width: w, height: h, borderwidth: 0, highlightthickness: 0, background: "darkgreen").place("x" => 0, "y" => 0)

    # 盤の周囲の文字
    for i in 0..BOARDSIZE-1 do
      TkcText.new(canvas, i*SWIDTH + SWIDTH/2 + MARGIN - 4, MARGIN - 10, text: ("a".ord + i).chr, fill: "white")
      TkcText.new(canvas, 10, i*SWIDTH + SWIDTH/2 + MARGIN, text: (i+1).to_s, fill: "white")
    end

    # 8x8のマス目を描く
    self.drawBoard(canvas)

    # 終了ボタンと再スタートボタン
    bframe = TkFrame.new(top, width: w, height: BHEIGHT).place('x' => '0', 'y' => h)
    TkButton.new(bframe, text: 'プログラム終了', command: proc{exit}).pack('side' => 'left')
    TkButton.new(bframe, text: '再スタート', command: proc{reset(canvas)}).pack('side' => 'left')

    # 動作確認用メッセージの表示領域, TkTextでテキストを表示
    # TkScrollbarのスクロールバー付きにする
    frame = TkFrame.new(top, width: w, background: "red", height: MHEIGHT).place("x" => 0, "y" => h + BHEIGHT)
    yscr = TkScrollbar.new(frame).pack("fill"=>"y", "side"=>"right", "expand" => true)
    text = TkText.new(frame, height: 6).pack("fill" => "both", "side"=>"right", "expand" => true)
    text.yscrollbar(yscr)

    # 盤がクリックされた場所の動作を定義、クリックされるとclickBoardが呼び出される
    canvas.bind("ButtonPress-1", proc{|x,y|
                  self.clickBoard(canvas, text, x, y)
                  },"%x %y")
    
    return canvas
  end

  def drawBoard(canvas)
    # マスを1つ描く(サンプル)
    #rect = TkcRectangle.new(canvas, MARGIN, MARGIN, MARGIN + SWIDTH, MARGIN + SWIDTH)
    #rect.configure(fill: "#00aa00")

    # 8x8=64個のマスを描く
    for x in 0..BOARDSIZE-1 do
      for y in 0..BOARDSIZE-1 do
        rect = TkcRectangle.new(canvas, MARGIN+SWIDTH*x, MARGIN+SWIDTH*y, MARGIN+SWIDTH*(x+1), MARGIN+SWIDTH*(y+1))
        rect.configure(fill: "#00aa00")
      end
    end
  end

  # すべての石を描画
  def drawAllDisks(canvas)
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        # 石の描画
        if @rawBoard[x][y] == -1 # その値がBLACKかWHITEなら以下を実行
          disk = TkcOval.new(canvas, MARGIN+SWIDTH*(x-1), MARGIN+SWIDTH*(y-1), MARGIN+SWIDTH*x, MARGIN+SWIDTH*y)  # 適切な位置に円を描く
          disk.configure(fill: "white")
        elsif @rawBoard[x][y] == 1
          disk = TkcOval.new(canvas, MARGIN+SWIDTH*(x-1), MARGIN+SWIDTH*(y-1), MARGIN+SWIDTH*x, MARGIN+SWIDTH*y)  # 適切な位置に円を描く
          disk.configure(fill: "black")
        end
      end
    end  
  end

  def clickBoard(canvas,text,x,y)
    # クリックされた座標 (x,y)から盤の位置 (x1,y1)を得る
    # ここに，xの値から x1を計算する
    if MARGIN+SWIDTH*0 < x and x < MARGIN+SWIDTH*1
      x1 = 1
    elsif MARGIN+SWIDTH*1 < x and x < MARGIN+SWIDTH*2
      x1 = 2
    elsif MARGIN+SWIDTH*2 < x and x < MARGIN+SWIDTH*3
      x1 = 3
    elsif MARGIN+SWIDTH*3 < x and x < MARGIN+SWIDTH*4
      x1 = 4
    elsif MARGIN+SWIDTH*4 < x and x < MARGIN+SWIDTH*5
      x1 = 5
    elsif MARGIN+SWIDTH*5 < x and x < MARGIN+SWIDTH*6
      x1 = 6
    elsif MARGIN+SWIDTH*6 < x and x < MARGIN+SWIDTH*7
      x1 = 7
    elsif MARGIN+SWIDTH*7 < x and x < MARGIN+SWIDTH*8
      x1 = 8
    end

    # ここに，yの値から y1を計算する
    if MARGIN+SWIDTH*0 < y and y < MARGIN+SWIDTH*1
      y1 = 1
    elsif MARGIN+SWIDTH*1 < y and y < MARGIN+SWIDTH*2
      y1 = 2
    elsif MARGIN+SWIDTH*2 < y and y < MARGIN+SWIDTH*3
      y1 = 3
    elsif MARGIN+SWIDTH*3 < y and y < MARGIN+SWIDTH*4
      y1 = 4
    elsif MARGIN+SWIDTH*4 < y and y < MARGIN+SWIDTH*5
      y1 = 5
    elsif MARGIN+SWIDTH*5 < y and y < MARGIN+SWIDTH*6
      y1 = 6
    elsif MARGIN+SWIDTH*6 < y and y < MARGIN+SWIDTH*7
      y1 = 7
    elsif MARGIN+SWIDTH*7 < y and y < MARGIN+SWIDTH*8
      y1 = 8
    end

    # 座標を表示する（動作確認用）
    msg = "(x,y) = (" + x.to_s + "," + y.to_s + ") (x1,y1) = (" + x1.to_s + "," + y1.to_s + ")\n"
    text.insert("1.0", msg)

    # 座標が盤の範囲外であれば何もせず return
    if !((1..BOARDSIZE).include? x1) or !((1..BOARDSIZE).include? y1)
      return
    end

    # 石を打ってひっくり返す、打てないなら何もせずreturn
    if !self.move(x1, y1)
      return
    end

    # 石を再描画
    self.drawAllDisks(canvas)
    Tk.update

    # ゲーム終了
    if self.isGameOver
      text.insert("1.0", "ゲーム終了\n")
    end

    # パスの場合は手番を入れ替えて@movableDirを更新
    if self.isPass
      @current_color = -@current_color
      self.initMovable
      text.insert("1.0", "パス\n")
      return
    end
    
    # ゲーム終了か，人間が打てるようになるまでコンピュータの手を生成
    loop do
      maxScore = -MAXSCORE
      xmax = 0
      ymax = 0

      # すべての打てる手を生成し，それぞれの手を minmax で探索
      for x in 1..BOARDSIZE do
        for y in 1..BOARDSIZE do
          if @movableDir[x][y] != NONE
            # 状態を保存
            tmpBoard = @rawBoard.map(&:dup)
            tmpDir = @movableDir.map(&:dup)
            tmpTurns = @turns
            tmpColor = @current_color

            self.move(x,y)
            # 残り手数が LIMIT2 以下の場合は，終盤とする（最後まで読み切る）
            if MAXTURNS - @turns <= LIMIT2
              mode = 1
              limit = LIMIT2
            # そうでなければ，終盤でない（深さ LIMIT まで探索）
            else
              mode = 0
              limit = LIMIT
            end
            
            score = -alphabeta(limit - 1, mode, -MAXSCORE, MAXSCORE)
            text.insert('1.0', "(x,y) = ("+ x.to_s + ","+ y.to_s + "),score = " + score.to_s + "\n")

            # 元に戻す
            @rawBoard = tmpBoard.map(&:dup)
            @movableDir = tmpDir.map(&:dup)
            @turns = tmpTurns
            @current_color = tmpColor

            if maxScore < score
              maxScore = score
              xmax = x
              ymax = y
            end
          end
        end
      end

      # 最もスコアの高いところに石を置く
      self.move(xmax,ymax)
      self.drawAllDisks(canvas)
      text.insert('1.0', "選択されたのは (x,y) = ("+ xmax.to_s + ","+ ymax.to_s + "),score = " + maxScore.to_s + "\n")
      Tk.update

      # ゲーム終了ならループを抜ける
      if self.isGameOver
        score_black = 0
        score_white = 0
  
        for x in 1..BOARDSIZE do
          for y in 1..BOARDSIZE do
            # @rawBoard[x][y] が @current_color ならば，socre を 1 加算
            if @rawBoard[x][y] == WHITE
              score_white += 1
            end
            # @rawBoard[x][y] が -@current_color ならば，socre を 1 減算
            if @rawBoard[x][y] == BLACK
              score_black += 1
            end
          end
        end

        if score_black > score_white
          text.insert('1.0', "ゲーム終了\n" + "石差" + (score_black - score_white).to_s + "で黒の勝ちです。\n")
        elsif score_black < score_white
          text.insert('1.0', "ゲーム終了\n" + "石差" + (score_white - score_black).to_s + "で白の勝ちです。\n")
        else
          text.insert('1.0', "ゲーム終了\n" + "引き分けです。\n")
        end
        break
      # 人間がパスの場合，手番を入れ替える（ループは抜けない）
      elsif self.isPass
        @current_color = -@current_color
        self.initMovable
        text.insert('1.0', "パス\n")
      # そうでなければ，人間が打てるのでループを抜ける
      else
        break
      end
    end
  end

  def alphabeta(limit, mode, alpha, beta)
    score = 0
    maxScore = -MAXSCORE
    
    # 探索の深さ限度に到達したか，ゲーム終了の場合は評価値を返す
    if limit == 0 or self.isGameOver
      return self.evaluate(mode)
    end
      
    # パスの場合は，手番を変えて探索を続ける
    if self.isPass
    
      # 状態を保存
      tmpBoard = @rawBoard.map(&:dup)
      tmpDir = @movableDir.map(&:dup)
      tmpTurns = @turns
      tmpColor = @current_color
      
      # 色を反転して探索
      @current_color = -@current_color
      self.initMovable
      score = -alphabeta(limit - 1, mode, -beta, -alpha)
      
      # 元に戻す
      @rawBoard = tmpBoard.map(&:dup)
      @movableDir = tmpDir.map(&:dup)
      @turns = tmpTurns
      @current_color = tmpColor

      return score
    end

    # パスでない場合は，すべての打てる手を生成し，スコアの最も高いものを探す
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        if @movableDir[x][y] != NONE

          # 現在の盤の状態を保存
          # p.2 の 13-16 行目（または上記の 15-18 行目）と同様に，
          # 盤の状態を保存するコードを書く
          tmpBoard = @rawBoard.map(&:dup)
          tmpDir = @movableDir.map(&:dup)
          tmpTurns = @turns
          tmpColor = @current_color       
          
          # 石を打つ
          self.move(x,y)

          # alphabetaを呼び出す
          score = -alphabeta(limit - 1, mode, -beta, -alpha)
          
          # 盤の状態を元に戻す
          # p.3 の 34-37 行目（または上記の 26-29 行目）と同様に，
          # 盤の状態を元に戻すコードを書く
          @rawBoard = tmpBoard.map(&:dup)
          @movableDir = tmpDir.map(&:dup)
          @turns = tmpTurns
          @current_color = tmpColor
          
          if score > alpha
            alpha = score
          end

          if alpha >= beta
            return alpha
          end
        end
      end
    end
    return alpha
  end

  # 石の数を数える
  def numDisks
    score = 0

    # 単純に「石の数が多いほど有利！」と考えて
    # 「自分 (@current_color) の数」 - 「相手 (-@current_color) の石の数」
    # を計算し，score に代入して return する
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        # @rawBoard[x][y] が @current_color ならば，socre を 1 加算
        if @rawBoard[x][y] == @current_color
          score += 1
        end
        # @rawBoard[x][y] が -@current_color ならば，socre を 1 減算
        if @rawBoard[x][y] == -@current_color
          score -= 1
        end
      end
    end
    return score
  end

  # 評価関数(改良版)
  def evaluate(mode)

    # 重みを設定（各自でいろいろな値を試してみる．w2 は大きめの方がよい）
    w1 = 4
    w2 = 40

    if mode == 1
      score = self.numDisks + self.checkX + self.checkC
    else
      score = w1 * self.movility + w2 * self.checkCorner + self.checkX + self.checkC
    end

    return score
  end

  # 再スタートボタンが押された時に呼び出されるメソッド
  def reset(canvas)
    res = TkDialog.new('message'=>' 黒と白，どちらにします？','buttons'=>' 黒にする 白にする', 'default'=>0).value

    # 盤を初期化
    self.init

    # 人間が白を選んだ場合，まずコンピュータが黒で (4,3) に打つ
    if res == 1
      self.move(4,3)
    end

    # 盤と石を再描画
    self.drawBoard(canvas)
    self.drawAllDisks(canvas)
  end

  def movility
    score = 0

    # 打てる場所が多いほど有利と考えて，
    # 「自分の打てるマスの数」- 「相手の打てるマスの数」を計算する
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        # 自分の手数：@movableDir[x][y] の値を調べて，
        if @movableDir[x][y] != NONE
          # NONE でなければ
          # score に 1 加算する
          score += 1
        # 相手の手数：self.checkMobility(x,y,-@current_color) の値を調べて，
        end
        if self.checkMobility(x,y,-@current_color) != NONE
          # NONE でなければ
          # score を 1 減算する
          score -= 1
        end
      end
    end
    return score
  end

  # 隅に石が置かれているかを評価する
  def checkCorner
    score = 0

    for x in [1,BOARDSIZE] do
      for y in [1,BOARDSIZE] do
        # @rawBoard[x][y] が自分の石 (@current_color) ならば
        if @rawBoard[x][y] == @current_color
        # score に 1 加算
          score += 1
        end
        # @rawBoard[x][y] が相手の石 (-@current_color) ならば
        if @rawBoard[x][y] == -@current_color
        # score を 1 減算
          score -= 1
        end
      end
    end
    return score
  end

  def checkX
    score = 0

    if @rawBoard[1][1] != NONE
      if @rawBoard[2][2] == @current_color
        score += 1
      end
      if @rawBoard[2][2] == -@current_color
        score -= 1
      end
    end

    if @rawBoard[1][8] != NONE
      if @rawBoard[2][7] == @current_color
        score += 1
      end
      if @rawBoard[2][7] == -@current_color
        score -= 1
      end
    end

    if @rawBoard[8][1] != NONE
      if @rawBoard[7][2] == @current_color
        score += 1
      end
      if @rawBoard[7][2] == -@current_color
        score -= 1
      end
    end

    if @rawBoard[8][8] != NONE
      if @rawBoard[7][7] == @current_color
        score += 1
      end
      if @rawBoard[7][7] == -@current_color
        score -= 1
      end
    end

    return score
  end

  def checkC
    score = 0
    count_line = 0

    for y in 1..BOARDSIZE do
      if y == 1 or y == 8
        for x in 1..BOARDSIZE do
          if @rawBoard[x][y] != NONE
            count_line += 1
          end
          if count_line == 1 and (@rawBoard[2][y] == @current_color or @rawBoard[7][y] == @current_color)
            score -= 1
          end
        end
      end
    end

    for x in 1..BOARDSIZE do
      if x == 1 or x == 8
        for y in 1..BOARDSIZE do
          if @rawBoard[x][y] != NONE
            count_line += 1
          end
          if count_line == 1 and (@rawBoard[x][2] == @current_color or @rawBoard[x][7] == @current_color)
            score -= 1
          end
        end
      end
    end
    return score
  end
end

# Boardインスタンスの生成
board = Board.new

# 盤を初期化
board.init
# loopの実行（コメントは後で外す）
#board.loop
canvas = board.makeWindow
board.drawAllDisks(canvas)
Tk.mainloop
