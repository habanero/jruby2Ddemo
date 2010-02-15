#
#  Image画像を管理するクラス
#

class ResourceManager
  @instance = nil
  def self.instance
    return @instance if @instance
    @instance = new
  end
  private_class_method(:new)

  def initialize()
    @cache = {}
    load_resource
  end

  def fetch(name)
    @chache[name]
  end

  private
  def load_resource
    resource_files.each do |name|
      path = File.join(resource_dir, name)
      @cache[name] = __load_resource(path)
    end
  end

  def __load_resource(path)
    # リソースをロードする処理
  end

  def resource_dir
    ""
  end

  def resource_files
    []
  end
end

class DemoImages < ResourceManager
  private
  def __load_resource(path)
    javax.imageio.ImageIO.read(java.io.File.new(path))
  end
  
  def resource_dir
    "images"
  end

  def resource_files
    ["ruby.gif"]
  end
end