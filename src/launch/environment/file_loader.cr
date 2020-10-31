# This file loads all the .yml files in config/environments for ecr processing.

class FileLoader
  @current_dir : String
  @testing_path : String
  @data : String
  @path : String

  def initialize(path : String)
    @data = ""
    @current_dir = Dir.current
    @path = @current_dir + path
    @testing_path = @current_dir + "/spec/support/config"
  end

  # Iterate through files generating a string that will be turned into code.
  # Adds the output of `ECR.render` to `@environment_files`
  def generate_code : String
    files = fetch_files

    files.each { |file| @data += code(file) }
    @data
  end

  private def fetch_files : Array(String)
    if File.exists?(path)
      Dir.children(path).reject! { |f| ext(f) != "yml" }
    elsif File.exists?(@testing_path)
      @path = @testing_path
      Dir.children(@testing_path).reject! { |f| ext(f) != "yml" }
    else
      raise File::NotFoundError.new(@path, file: ARGV[0])
    end
  end

  private def ext(file : String) : String
    split(file).last
  end

  private def file_name(file : String) : String
    split(file).first
  end

  private def split(file : String) : Array(String)
    file.split(".")
  end

  private def code(file : String) : String
    "environment_files[\"#{file_name(file)}\"] = ECR.render \"#{path}/#{file}\"\n"
  end

  private def path : String
    @path
  end
end

puts FileLoader.new(ARGV[0]).generate_code
