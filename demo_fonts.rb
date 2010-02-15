#
#  Fontを管理するクラス
#

class DemoFonts < ResourceManager
  private
  def __load_resource(path)
    is = java.io.FileInputStream.new(path)
    java.awt.Font.createFont(java.awt.Font::TRUETYPE_FONT, is);
  end

  def resource_dir
    "fonts"
  end

  def resource_files
    ["ipam.otf"]
  end
end