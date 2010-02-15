include Java

%w( jruby2d_demo memory_monitor demo_images demo_fonts
   ).each do |filename|
  require File.join(File.dirname(__FILE__), filename)
end

JRuby2Ddemo.start