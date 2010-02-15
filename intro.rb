include Java

class Intro < javax.swing.JPanel
  MY_BLACK  = java.awt.Color.new( 20,  20,  20)
  MY_WHITE  = java.awt.Color.new(240, 240, 255)
  MY_RED    = java.awt.Color.new(149,  43,  42)
  MY_BLUE   = java.awt.Color.new( 94, 105, 176)
  MY_YELLOW = java.awt.Color.new(255, 255, 140)

  def initialize
    super()
    eb = javax.swing.border.EmptyBorder.new(80,110,80,110)
    bb = javax.swing.border.BevelBorder.new(javax.swing.border.BevelBorder::LOWERED)
    setBorder(javax.swing.border.CompoundBorder.new(eb, bb))
    setLayout(java.awt.BorderLayout.new)
    setBackground(java.awt.Color::GRAY)

    setToolTipText("click for scene table")

    @surface = Surface.new
    add(@surface)
    # TODO
    # implement addMouseListener
  end

  def start
    @surface.start()
  end

  class Surface < javax.swing.JPanel
    include java.lang.Runnable

    def initialize()
      super()
      setBackground(MY_BLACK)
      setLayout(java.awt.BorderLayout.new)
      # TODO
      # implement addMouseListener

      # TODO
      # demoイメージを用意する
      # @cupanim = DemoImages.instance.fetch("cupanim.gif")
      # @java_logo = DemoImages.instance.fetch("java_logo.png")

      @scenes = Director.create_scenes
      @index = 0
      @thread = nil
      @sleep_amt = 0.03     # 30msec ごとに描画メソッドを実行

      @bimg = nil
    end

    def start
      @thread = java.lang.Thread.new(self)
      @thread.start
    end

    def paint(g)
      d = getSize()
      return if (d.width <= 0 || d.height <=0)

      if(@bimg.nil? || @bimg.getWidth() != d.width || @bimg.getHeight() != d.height)
        @bimg = getGraphicsConfiguration().createCompatibleImage(d.width, d.height)
      end

      g2 = @bimg.createGraphics()
      g2.setRenderingHint(java.awt.RenderingHints::KEY_ANTIALIASING,
                          java.awt.RenderingHints::VALUE_ANTIALIAS_ON);
      g2.setBackground(getBackground())
      @scenes[@index].step(d.width, d.height)
      @scenes[@index].render(d.width, d.height, g2)
      g2.dispose()

      g.drawImage(@bimg, 0, 0, self)
    end

    def run
      # TODO
      # window非表示の時、スレッドを止める

      while(@thread)
        d = getSize()
        @scenes[@index].reset(d.width, d.height)
        until @scenes[@index].animate_end?
          repaint
          sleep(@sleep_amt)
        end
        @index += 1
        @index =0 if @index >= @scenes.size
      end
    end
  end

  class Director
    def initialize
      @gp = java.awt.GradientPaint.new(0, 40 , MY_BLUE, 38, 2, MY_BLACK)
      @f1 = java.awt.Font.new("serif", java.awt.Font::PLAIN, 200)
      @f2 = java.awt.Font.new("serif", java.awt.Font::PLAIN, 120)
      @f3 = java.awt.Font.new("serif", java.awt.Font::PLAIN, 72)
    end

    def self.create_scenes
      scenes = []
=begin
      txe = TxE.new("J",
                     java.awt.Font.new("serif", java.awt.Font::PLAIN, 150),
                     MY_YELLOW,
                     30,
                     TxE::Scale)
      gpe = GpE.new(MY_BLACK, MY_BLUE, 30, GpE::Mixed)
      scenes << Scene.new([ClearBackground.new, gpe, txe])

      txe = TxE.new("2",
                     java.awt.Font.new("serif", java.awt.Font::PLAIN, 150),
                     MY_YELLOW,
                     30,
                     TxE::Rotate)
      gpe = GpE.new(MY_BLUE, MY_BLACK, 30, GpE::Mixed)
      scenes << Scene.new([gpe, txe])

      txe = TxE.new("D",
                     java.awt.Font.new("serif", java.awt.Font::PLAIN, 150),
                     MY_YELLOW,
                     30,
                     TxE::Scale)
      gpe = GpE.new(MY_BLACK, MY_BLUE, 30, GpE::Mixed)
      scenes << Scene.new([gpe, txe])

      txe = TxE.new("JRuby2D",
                     java.awt.Font.new("serif", java.awt.Font::PLAIN, 100),
                     MY_YELLOW,
                     30,
                     TxE::Rotate)
      gpe = GpE.new(MY_BLUE, MY_BLACK, 25, GpE::Horizontally)
      scenes << Scene.new([gpe, txe])

      scenes << Scene.new([DdE.new(50, 2)])
      scenes << Scene.new([ClearBackground.new, TwoRectangle.new(40), Features.new(["Graphics", "Antialiased rendering", "Bezier paths","Transforms", "Compositing", "Stroking parameters"])])
      scenes << Scene.new([ClearBackground.new])
=end


            txe = TxE.new("JRuby2D",
                     java.awt.Font.new("serif", java.awt.Font::PLAIN, 100),
                     nil,
                     50,0,
                     TxE::Nothing, TxE::Alpha)
      scenes << Scene.new([TpE.new(MY_BLACK, MY_BLUE, 40, 40, 0, TpE::SicleRect),
                           FillRect.new(), TpE.new(MY_BLACK, MY_YELLOW, 4, 25), txe])
      scenes << Scene.new([CoE.new(30, 0, CoE::Circle)])
      scenes
    end
  end


  # アニメーションのTemplate
  #
  # サブクラスが実装するメソッド
  # __reset, __step, __render
  #
  class AnimateTemplate
    # === 引数
    #
    # +count+::
    # アニメーションの実行回数
    #
    # +start_delay+::
    # 初期遅延
    #
    def initialize(count, start_delay)
      @count, @start_delay = count, start_delay
      @index = @delay_index = 0
    end

    # === 引数
    #
    # +w+::
    # 描画ComponentのWidth
    #
    # +h+::
    # 描画ComponentのHeight
    #
    # === 詳細
    #
    # アニメーションを初期化する時に呼ばれる
    def reset(w, h)
      @index = @delay_index = 0
      __reset(w, h) if respond_to?(:__reset)
    end

    # === 引数
    #
    # +w+::
    # 描画ComponentのWidth
    #
    # +h+::
    # 描画ComponentのHeight
    #
    # === 詳細
    #
    # renderの前に呼ばれるメソッド  see Serface#paint
    def step(w, h)
      if start_delay_end?
        __step(w, h) if respond_to?(:__step)
        @index += 1 unless animate_end?
      else
        @delay_index += 1
      end
    end

    # === 引数
    #
    # +w+::
    # 描画ComponentのWidth
    #
    # +h+::
    # 描画ComponentのHeight
    #
    # +g+::
    # 描画ComponentのGraphicsオブジェクト
    def render(w, h, g)
      __render(w, h, g) if start_delay_end?
    end

    # === 詳細
    # 
    # 線形補間。0.0～1.0の数値を返す。(桁数：小数点第３位)
    def fraction
      x = 10**3
      [((@index.to_f / @count.to_f) * x).floor.quo(x), 1.0].min
    end

    def start_delay_end?
      @delay_index >= @start_delay
    end

    def animate_end?
      @index > @count
    end
  end

  class TxE < AnimateTemplate
    def initialize(text, font, paint, count, start_delay=0, type=Rotate, alpha=NotAlpha)
      super(count, start_delay)
      @paint = paint

      frc = java.awt.font.FontRenderContext.new(nil, true, true)
      tl = java.awt.font.TextLayout.new(text, font, frc)

      @sw = tl.getOutline(nil).getBounds().getWidth()

      @shapes = []
      @tx_shapes = []
      text.each_char do |c|
        @shapes.push(java.awt.font.TextLayout.new(c, font, frc).getOutline(nil))
      end

      extend type
      extend alpha
    end

    def __step(w, h)
      char_width = w/2 - @sw/2
      @tx_shapes = @shapes.map do |s|
        at = affine_transform(w, h, s, char_width)
        char_width += (s.getBounds().getWidth() + 1)
        at.createTransformedShape(s)
      end
    end
    
    def __render(w, h, g)
      save_ac = g.getComposite()
      g.setComposite(alpha_composite())
      g.setPaint(@paint) if @paint
      @tx_shapes.each{|s| g.fill(s)}
      g.setComposite(save_ac)
    end

    module Rotate

      def affine_transform(w, h, shape, char_width)
        bounds = shape.getBounds()
        at = java.awt.geom.AffineTransform.new
        at.translate(char_width, h/2 + bounds.getHeight()/2)
        s = at.createTransformedShape(shape)
        b1 = s.getBounds()

        at.rotate(rotate_angle)
        at.scale(scale_value, scale_value)
        s = at.createTransformedShape(shape)
        b2 = s.getBounds2D()

        xx =   (b1.getX()+b1.getWidth()/2) - (b2.getX()+b2.getWidth()/2)
        yy =   (b1.getY()+b1.getHeight()/2) - (b2.getY()+b2.getHeight()/2)
        to_center_at = java.awt.geom.AffineTransform.new
        to_center_at.translate(xx, yy)
        to_center_at.concatenate(at)
        to_center_at
      end

      def rotate_angle
        rotate = fraction * 360.0 * 2  # rotate 2 times
        java.lang.Math.toRadians(rotate)
      end

      def scale_value
        fraction * 1.0
      end
    end

    module Scale
      include Rotate
      def rotate_angle
        0
      end
    end

    module Nothing
      include Rotate
      def rotate_angle
        0
      end

      def scale_value
        1.0
      end
    end

    module Alpha
      def alpha_composite
        java.awt.AlphaComposite.getInstance(java.awt.AlphaComposite::SRC_OVER, fraction**2)
      end
    end

    module NotAlpha
      def alpha_composite
        java.awt.AlphaComposite.getInstance(java.awt.AlphaComposite::SRC_OVER, 1.0)
      end
    end
  end

  class GpE < AnimateTemplate
    def initialize(color1, color2, count, start_delay=0, type=Vertically)
      super(count, start_delay)
      @color1, @color2 = color1, color2
      @rect = []
      @grad = []

      @incr = 1.0 / (@count)

      extend type
    end

    def __render(w, h, g)
      @grad.each_with_index do |grad, i|
        g.setPaint(grad)
        g.fill(@rect[i])
      end
    end

    module Vertically
      def __step(w, h)
        @rect = []
        @grad = []
        w2 = w * 0.5
        x1 = w * (1.0 - fraction)
        x2 = w * fraction
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, 0, w2, h)
        @rect << java.awt.geom.Rectangle2D::Float.new(w2, 0, w-w2, h)
        @grad << java.awt.GradientPaint.new(0, 0, @color1, x1, 0, @color2)
        @grad << java.awt.GradientPaint.new(x2, 0, @color2, w, 0, @color1)
      end
    end

    module Vertically2
      def __step(w, h)
        @rect = []
        @grad = []
        w2 = w * fraction
        x1 = x2 = w2
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, 0, w2, h)
        @rect << java.awt.geom.Rectangle2D::Float.new(w2, 0, w-w2, h)
        @grad << java.awt.GradientPaint.new(0, 0, @color1, x1, 0, @color2)
        @grad << java.awt.GradientPaint.new(x2, 0, @color2, w, 0, @color1)
      end
    end

    module Horizontally
      def __step(w, h)
        @rect = []
        @grad = []
        h2 = h * 0.5
        y1 = h * (1.0 - fraction)
        y2 = h * fraction
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, 0, w, h2)
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, h2, w, h-h2)
        @grad << java.awt.GradientPaint.new(0, 0, @color1, 0, y1+30, @color2)
        @grad << java.awt.GradientPaint.new(0, y2-30, @color2, 0, h, @color1)
      end
    end

    module Horizontally2
      def __step(w, h)
        @rect = []
        @grad = []
        h2 = h * fraction
        y1 = y2 = h2
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, 0, w, h2)
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, h2, w, h-h2)
        @grad << java.awt.GradientPaint.new(0, 0, @color1, 0, y1, @color2)
        @grad << java.awt.GradientPaint.new(0, y2, @color2, 0, h, @color1)
      end
    end

    module Mixed
      def __step(w, h)
        @rect = []
        @grad = []
        w2 = w/2.0
        h2 = h/2.0
        @rect << java.awt.geom.Rectangle2D::Float.new( 0,   0,  w2, h2+1)
        @rect << java.awt.geom.Rectangle2D::Float.new(w2,   0,  w2, h2+1)
        @rect << java.awt.geom.Rectangle2D::Float.new( 0, h2-1, w2, h2+1)
        @rect << java.awt.geom.Rectangle2D::Float.new(w2, h2-1, w2, h2+1)

        x1 = w * (1.0 - fraction)
        x2 = w * fraction
        y1 = h * (1.0 - fraction)
        y2 = h * fraction

        @grad << java.awt.GradientPaint.new( -1,  -1, @color1, x1, y1, @color2)
        @grad << java.awt.GradientPaint.new(w+1,  -1, @color1, x2, y1, @color2)
        @grad << java.awt.GradientPaint.new( -1, h+1, @color1, x1, y2, @color2)
        @grad << java.awt.GradientPaint.new(w+1, h+1, @color1, x2, y2, @color2)
      end
    end
  end

  class Padding < AnimateTemplate
    def initialize(count, start_delay=0)
      super(count, start_delay)
    end

    def render(w, h, g)
      # noting to do
    end
  end

  class FillRect
    def initialize(paint=nil)
      @paint = paint
    end

    def reset(w, h)
      # noting to do
    end

    def step(w, h)
      # noting to do
    end

    def render(w, h, g)
      g.setPaint(@paint) if @paint
      g.fillRect(0, 0, w, h)
    end

    def animate_end?
      true
    end
  end

  class DdE < AnimateTemplate
    def initialize(block_size, count, start_delay=0, erase_count=1500)
      super(count, start_delay)
      @block_size = block_size
      @erase_count = erase_count
    end

    def __reset(w, h)
      @width, @height = w, h
    end

    def __render(w, h, g)
      g.setColor(MY_BLACK)
      f = 3.0 * fraction()
      @erase_count.times do |i|
        x, y = rand(@width), rand(@height)
        i % 2 == 0 ? (x_f, y_f = 1, f) : (x_f, y_f = f, 1)
        g.fillRect(x, y, @block_size*x_f, @block_size*y_f)
      end
    end
  end

  class TwoRectangle < AnimateTemplate
    def initialize(count, start_delay=0)
      super(count, start_delay)

      @x = @y = nil
      @x_incr = @y_incr = nil
      @end_x = @end_y = nil

      @rect1 = nil
      @rect2 = nil
    end

    def create_rectangle(w, h)
      @rect1 = java.awt.Rectangle.new(8, 20, w-20, 30)
      @rect2 = java.awt.Rectangle.new(20, 8, 30, h-20)
    end

    def __reset(w, h)
      create_rectangle(w, h)
      @x_incr = w.to_f / (@count)
      @y_incr = h.to_f / (@count)
      @x = w + @x_incr * 1.4
      @y = h + @y_incr * 1.4
      @end_x = w / 40
      @end_y = h / 40
    end

    def __step(w, h)
      @x -= @x_incr
      @y -= @y_incr
      @x = @end_x if @x < @end_x
      @y = @end_y if @y < @end_y

      @rect1.setLocation(@x, 20)
      @rect2.setLocation(20, @y)
    end

    def __render(w, h, g)
      g.setColor(MY_BLUE)
      g.fill(@rect1)
      g.setColor(MY_RED)
      g.fill(@rect2)
    end
  end

  class TpE < AnimateTemplate
    def initialize(paint1, paint2, size, count, start_delay=0 ,type=Circle)
      super(count, start_delay)
      @paint1, @paint2, @size= paint1, paint2, size

      @bimg = java.awt.image.BufferedImage.new(@size, @size, java.awt.image.BufferedImage::TYPE_INT_RGB)
      @rect = java.awt.Rectangle.new(0, 0, @size, @size)
      @texture = nil
      extend type
    end

    def __step(w, h)
      g2 = @bimg.createGraphics()
      g2.setPaint(@paint1)
      g2.fillRect(0, 0, @size, @size)
      g2.setPaint(paint())
      g2.fill(shape(w, h))
      g2.dispose()
      @texture = java.awt.TexturePaint.new(@bimg, @rect)
    end

    def __render(w, h, g)
      g.setPaint(@texture)
    end
    
    module Circle
      def paint
        @paint2
      end

      def shape(w, h)
        java.awt.geom.Ellipse2D::Float.new(0, 0, @size*0.8*fraction, @size*0.8*fraction)
      end
    end

    module Rect
      def paint
        java.awt.GradientPaint.new(0, @size, @paint2, @size, 0, @paint1)
      end

      def shape(w, h)
        java.awt.geom.Rectangle2D::Float.new(0, 0, @size*fraction, @size*fraction)
      end
    end

    module ReverseRect
      def paint
        java.awt.GradientPaint.new(0, @size, @paint2, @size, 0, @paint1)
      end

      def shape(w, h)
        f = 1.0 - fraction
        java.awt.geom.Rectangle2D::Float.new(0, 0, @size*f, @size*f)
      end
    end

    module SicleRect
      def paint
        java.awt.GradientPaint.new(0, @size, @paint2, @size, 0, @paint1)
      end

      def shape(w, h)
        java.awt.geom.Rectangle2D::Float.new(0, 0, @size*__fraction, @size*__fraction)
      end

      def __fraction
        ret = 0
        f = fraction()
        if f < 0.333
          ret = f * 3
        elsif f < 0.666
          ret = 1.0 - (f-0.333)*3
        else
          ret = (f-0.666)*3
        end
        ret
      end
    end
  end

  class Features
    Font1 = java.awt.Font.new("serif", java.awt.Font::BOLD, 38)
    Font2 = java.awt.Font.new("serif", java.awt.Font::BOLD, 24)
    
    def initialize(lines)
      @lines = lines
      @text_size = @lines.inject(0){|result, s| result += s.size}

      @render_lines = []
      @fm1 = @fm2 = nil
      @index = 0
      @str_h = nil
    end

    def reset(w, h)
      @index = 0
      @fm1 = @fm2 = nil
    end

    def step(w, h)
      @render_lines = []
      index = @index

      @lines.each_with_index do |str, i|
        str.each_char do |c|
          @render_lines[i] ||= ""
          @render_lines[i] += c
          index -=1
          break if index < 0
        end
        break if index < 0
      end

      @index += 1
    end

    def render(w, h, g)
      research_font_metrics(g) if @fm1.nil?
      g.setColor(MY_WHITE)
      @render_lines.each_with_index do |line, i|
        font = (i==0 ? Font1 : Font2)
        x = (i==0 ? 90 : 120)
        g.setFont(font)
        g.drawString(line, x, 90+@str_h*i)
      end
    end

    def research_font_metrics(g)
      @fm1 = g.getFontMetrics(Font1)
      @fm2 = g.getFontMetrics(Font2)
      @str_h = @fm2.getAscent() + @fm2.getDescent()
    end

    def animate_end?
      @index >= @text_size
    end
  end

  class CoE <AnimateTemplate
    def initialize(count, start_delay=0, type=Circle)
      super(count, start_delay)
      @shape = nil
      extend type
    end

    def __step(w, h)
      outer = java.awt.geom.Area.new(java.awt.geom.Rectangle2D::Double.new(0, 0, w, h))
      outer.subtract(inner_area(w, h))
      @shape = outer
    end

    def __render(w, h, g)
      g.setColor(MY_BLACK)
      g.fill(@shape)
    end

    module Circle
      def inner_area(w, h)
        r = w *  (1.0 - fraction)
        x = w/2.0 - (r/2.0)
        y = h/2.0 - (r/2.0)
        java.awt.geom.Area.new(java.awt.geom.Ellipse2D::Double.new(x, y, r, r))
      end
    end

    module Rect
      def inner_area(w, h)
        r = ([w, h].min) * (1.0 - fraction)
        x = w/2.0 - (r/2.0)
        y = h/2.0 - (r/2.0)
        java.awt.geom.Area.new(java.awt.geom.Rectangle2D::Double.new(x, y, r, r))
      end
    end
  end

  class Scene
    def initialize(parts)
      @parts = parts

      @index = 0.0
    end

    def reset(w, h)
      @parts.each{|p| p.reset(w, h)}
    end

    def step(w, h)
      @parts.each{|p| p.step(w, h)}
    end

    def render(w, h, g)
      @parts.each{|p| p.render(w, h, g)}
    end

    def animate_end?
      @parts.all?{|p| p.animate_end? }
    end
  end
end


if __FILE__ == $0
  class DemoWindowAdaptor < java.awt.event.WindowAdapter
    def initialize()
      super()
    end

    def windowClosing(e); java.lang.System.exit(0); end
    def windowDeiconified(e); ; end
    def windowIconified(e); ; end
  end

  intro = Intro.new
  f = javax.swing.JFrame.new
  f.addWindowListener(DemoWindowAdaptor.new)
  f.getContentPane().add("Center", intro);
  f.pack

  screen_size = java.awt.Toolkit.getDefaultToolkit().getScreenSize()
  w, h = 720, 510
  f.setLocation(screen_size.width/2 - w/2, screen_size.height/2 - h/2)
  f.setSize(w,h)
  f.setVisible(true)
  intro.start
end