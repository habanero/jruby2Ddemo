

include Java

class MemoryMonitor < javax.swing.JPanel
  def initialize()
    super()
    setLayout(java.awt.BorderLayout.new)
    setBorder(javax.swing.border.TitledBorder.new(javax.swing.border.EtchedBorder.new(),"Memory Monitor"))

    @surf = Surface.new
    add_surf()
    
    @controls = javax.swing.JPanel.new
    @controls.setPreferredSize(java.awt.Dimension.new(135, 80))

    font = java.awt.Font.new("serif", java.awt.Font::PLAIN, 10)
    label = javax.swing.JLabel.new("Sample Rate")
    label.setFont(font)
    label.setForeground(java.awt.Color::BLACK)
    @controls.add(label)

    @tf = javax.swing.JTextField.new("1000")
    @tf.setPreferredSize(java.awt.Dimension.new(45, 20))
    @controls.add(@tf)

    label = javax.swing.JLabel.new("ms")
    label.setFont(font)
    label.setForeground(java.awt.Color::BLACK)
    @controls.add(label)

    @datastamp_cb = javax.swing.JCheckBox.new("Output Date Stamp")
    @datastamp_cb.setFont(font)
    @controls.add(@datastamp_cb)

    addMouseListener(MonitorMouseAdapter.new)
  end

  def add_surf
    @surf.start
    add(@surf)
  end

  def add_controls
    add(@controls)
  end

  class MonitorMouseAdapter < java.awt.event.MouseAdapter
    def initialize()
      super()
      @do_control = false
    end

    def mouseClicked(e)
      mon = e.getSource
      mon.removeAll()
      if(@do_control)
        mon.add_surf
        @do_control = false
      else
        mon.add_controls
        @do_control = true
      end
      mon.revalidate()
      mon.repaint()
    end
  end

  class Surface < javax.swing.JPanel
    include java.lang.Runnable

    def initialize
      super()
      setBackground(java.awt.Color::BLACK)
      addMouseListener(SurfaceMouseListener.new(self))

      @thread = nil
      @sleep_amount = 1000

      @w = @h = nil
      @bimg = @big = nil

      @mf_color = java.awt.Color.new(0, 100, 0)
      @mf_rect = java.awt.geom.Rectangle2D::Float.new
      @mu_rect = java.awt.geom.Rectangle2D::Float.new

      @graph_color = java.awt.Color.new(46, 139, 87)
      @graph_outline_rect = java.awt.Rectangle.new
      @graph_line = java.awt.geom.Line2D::Float.new
      @column_inc = 0

      @pts = []
      @pt_num = 0

      @font = java.awt.Font.new("Times New Roman", java.awt.Font::PLAIN, 11)
      @ascent = @descent = nil

      @r = java.lang.Runtime.getRuntime()
    end

    def paint(g)
      return unless @big

      @big.setBackground(getBackground())
      @big.clearRect(0, 0, @w, @h)

      free_memory, total_memory = @r.freeMemory, @r.totalMemory

      # Draw allocated and used string
      @big.setColor(java.awt.Color::GREEN)
      @big.drawString((total_memory/1024).to_s + "K allocated", 4.0,  @ascent + 0.5)
      used_str = ((total_memory - free_memory)/1024).to_s + "K used"
      @big.drawString(used_str, 4, @h - @descent)

      # Calculate remaining size
      ss_h = @ascent + @descent
      remaining_height = (@h - (ss_h)*2.0 - 0.5)
      block_height = remaining_height / 10.0
      block_width = 20.0
      remaining_width = @w - block_width - 10

      # Memory
      @big.setColor(@mf_color)
      mem_usage = ((free_memory/total_memory.to_f)*10).ceil
      10.times do |i|
        @big.setColor(java.awt.Color::GREEN) if (mem_usage-1) < i
        @mu_rect.setRect(5, ss_h+i*block_height, block_width, block_height-1)
        @big.fill(@mu_rect)
      end

      # Draw History Graph
      @big.setColor(@graph_color)
      graph_x = 30
      graph_y = ss_h.to_i
      graph_w = @w - graph_x - 5
      graph_h = remaining_height
      @graph_outline_rect.setRect(graph_x, graph_y, graph_w, graph_h)
      @big.draw(@graph_outline_rect)

      graph_row = (graph_h / 10)
      # Draw row
      graph_y.step(graph_h + graph_y, graph_row) do |i|
        @graph_line.setLine(graph_x, i, graph_x+graph_w, i)
        @big.draw(@graph_line)
      end

      # Draw animated column movement
      graph_column = (graph_w / 15)
      @column_inc = graph_column if @column_inc <= 0
      
      (graph_x+@column_inc).step(graph_w+graph_x, graph_column) do |i|
        @graph_line.setLine(i, graph_y, i, graph_y+graph_h)
        @big.draw(@graph_line)
      end
      @column_inc -= 1

      @big.setColor(java.awt.Color::YELLOW)
      @pts << (graph_y+graph_h*(free_memory/total_memory.to_f))
      x = graph_x + graph_w - @pts.length
      @pts.each_index do |i|
        next if i == 0
        @big.drawLine(x+i-1, @pts[i-1], x+i, @pts[i])
      end

      # グラフの左にはみ出る値を除く
      @pts.shift while(@pts.length >= graph_w)

      g.drawImage(@bimg, 0, 0, self)
    end

    def start
      @thread = java.lang.Thread.new(self)
      @thread.setPriority(java.lang.Thread::MIN_PRIORITY)
      @thread.setName("MemoryMonitor")
      @thread.start
    end

    def stop
      @thread = nil
      # TODO
      # jrubyだとnotifyがエラーになる
      # notify()
    end

    def run
      while(!isShowing())
        java.lang.Thread.sleep(500)
      end

      while(isShowing())
        d = getSize()
        if(d.width != @w || d.height != @h)
          @w, @h = d.width(), d.height()
          @bimg = createImage(@w, @h)
          @big = @bimg.createGraphics()

          @big.setFont(@font)
          fm = @big.getFontMetrics(@font)
          @ascent, @descent = fm.getAscent(), fm.getDescent()
        end
        repaint()
        java.lang.Thread.sleep(@sleep_amount)
      end
      @thread = nil
    end

    class SurfaceMouseListener < java.awt.event.MouseAdapter
      def initialize(surf)
        super()
        @surf = surf
      end
      def mouseClicked(e)
        t = @surf.instance_variable_get(:@thread)
        t ? @surf.stop : @surf.start
      end
    end
  end
end


if __FILE__ == $0

  class DemoWindowAdaptor < java.awt.event.WindowAdapter
    def initialize(monitor)
      super()
      @mon = monitor
    end
    
    def windowClosing(e); java.lang.System.exit(0); end
    def windowDeiconified(e); @mon.surf.start; end
    def windowIconified(e); @mon.surf.stop; end
  end


  f = javax.swing.JFrame.new
  mon = MemoryMonitor.new
  f.addWindowListener(DemoWindowAdaptor.new(mon))
  f.add(mon)
  f.pack
  f.setSize(200, 200)
  f.setVisible(true)
end