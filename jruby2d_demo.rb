
include Java

class JRuby2Ddemo < javax.swing.JPanel
  include java.awt.event.ActionListener
  include java.awt.event.ItemListener

  @@demo = nil
  @@progress_label = javax.swing.JLabel.new("Loading, please wait...")
  @@progress_bar = javax.swing.JProgressBar.new

  @@print_cb = javax.swing.JCheckBoxMenuItem.new("Default Printer")

  def initialize()
    super()

    setLayout(java.awt.BorderLayout.new)
    setBorder(javax.swing.border.EtchedBorder.new)

    add(create_menu_bar(), java.awt.BorderLayout::NORTH)

    @@progress_bar.setMaximum(13)
    @@progress_label.setText("Loading images")
    DemoImages.instance


    @@progress_bar.setValue(@@progress_bar.getValue() + 1);
    @@progress_label.setText("Loading fonts");
    DemoFonts.instance
  end

  def create_menu_bar
    # TODO
    # 下のメソッドは必要？
    #javax.swing.JPopupMenu.setDefaultLightWeightPopupEnabled(false)

    menu_bar = javax.swing.JMenuBar.new

    menu = javax.swing.JMenu.new("File")
    menu_bar.add(menu)
    @file_mi = javax.swing.JMenuItem.new("Exit")
    @file_mi.addActionListener(self)
    menu.add(@file_mi)

    option = javax.swing.JMenu.new("option")
    menu_bar.add(option)

    @controls_cb = javax.swing.JCheckBoxMenuItem.new("Global Controls", true)
    @memory_cb   = javax.swing.JCheckBoxMenuItem.new("Memory Monitor", true)
    @pref_cb     = javax.swing.JCheckBoxMenuItem.new("Performance Monitor", true)
    [@controls_cb, @memory_cb, @pref_cb].each do |i|
      i.addItemListener(self)
      option.add(i)
    end

    option.add(javax.swing.JSeparator.new)

    @cc_thread_cb = javax.swing.JCheckBoxMenuItem.new("Custom Controls Thread", true)
    @verbose_cb   = javax.swing.JCheckBoxMenuItem.new("verbose")
    [@cc_thread_cb, @verbose_cb].each do |i|
      i.addItemListener(self)
      option.add(i)
    end
    
    option.add(@@print_cb)
    option.add(javax.swing.JSeparator.new)

    @backg_mi = javax.swing.JMenuItem.new("Background Color")
    @run_mi   = javax.swing.JMenuItem.new("Run Window")
    @clone_mi = javax.swing.JMenuItem.new("Cloning Feature")
    [@backg_mi, @run_mi, @clone_mi].each do |i|
      i.addActionListener(self)
      option.add(i)
    end

    menu_bar
  end

  def actionPerformed(e)
    java.lang.System.exit(0) if e.getSource == @file_mi
  end

  def itemStateChanged(e)
    p e
  end

  def self.start
    frame = javax.swing.JFrame.new("JRuby 2D Demo")
    frame.setDefaultCloseOperation(javax.swing.JFrame::EXIT_ON_CLOSE)
    frame.getAccessibleContext().setAccessibleDescription("A sample application to demonstrate JRuby2D features")

    width, height = 400, 200
    frame.setSize(width, height)
    dim = java.awt.Toolkit.getDefaultToolkit().getScreenSize()
    frame.setLocation(dim.width/2 - width/2, dim.height/2 - height/2)
    frame.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor::WAIT_CURSOR))

    # TODO
    # WindowListener を設定する
    #

    javax.swing.JOptionPane.setRootFrame(frame)

    # プログレスバーを乗せるJPanelをつくる
    progress_panel = ProgressPane.new
    progress_panel.setLayout(javax.swing.BoxLayout.new(progress_panel, javax.swing.BoxLayout::Y_AXIS))
    frame.getContentPane().add(progress_panel, java.awt.BorderLayout::CENTER)

    # プログレスバー用のラベルを作る
    label_size = java.awt.Dimension.new(400, 20)    
    @@progress_label.setAlignmentX(java.awt.Component::CENTER_ALIGNMENT)
    @@progress_label.setMaximumSize(label_size)
    @@progress_label.setPreferredSize(label_size)
    progress_panel.add(@@progress_label)

    # パディング
    progress_panel.add(javax.swing.Box.createRigidArea(java.awt.Dimension.new(1, 20)))

    # プログレスバー
    @@progress_bar.setStringPainted(true)
    @@progress_label.setLabelFor(@@progress_bar)
    @@progress_bar.setAlignmentX(java.awt.Component::CENTER_ALIGNMENT)
    @@progress_bar.setMinimum(0)
    @@progress_bar.setValue(0)
    progress_panel.add(@@progress_bar);

    frame.setVisible(true)

    @@demo = new
    frame.getContentPane().removeAll()
    frame.getContentPane().setLayout(java.awt.BorderLayout.new)
    frame.getContentPane().add(@@demo, java.awt.BorderLayout::CENTER)

    # メインウィンドウの場所と大きさを設定
    width, height = 730, 570
    frame.setLocation(dim.width/2 - width/2, dim.height/2 - height/2)
    frame.setSize(width, height)
    frame.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor::DEFAULT_CURSOR))

    frame.validate()
    frame.repaint()
  end

  class ProgressPane < javax.swing.JPanel
    def getInsets
      java.awt.Insets.new(40,30,20,30)
    end
  end
end

