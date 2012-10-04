#!/usr/bin/env ruby
# Base16 Builder (https://github.com/chriskempson/base16-builder)

require "securerandom"
require "yaml"
require "erb"

class Theme
  
  attr_accessor :template

  def initialize
    @scheme_dir = "schemes"
    @template_dir = "templates"
    @output_dir = "output"
  end

  def build(scheme_file)
    
    if scheme_file then 
      build_single_scheme(scheme_file)
    else 
      build_all_schemes
    end
    
  end
  
  def build_all_schemes
    scheme_files = read_scheme_dir

    scheme_files.each do |scheme_file|
      build_single_scheme(scheme_file)
    end
  end
  
  def build_single_scheme(scheme_file)
    puts scheme_file
    scheme_data = read_scheme_file(scheme_file)
    parse_template_files(scheme_data)
  end

  def read_scheme_file(scheme_file)
    scheme_file = @scheme_dir + "/#{scheme_file}" 

    begin
      YAML.load_file(scheme_file)
    rescue StandardError
       abort(read_error_message(scheme_file))
    end
  end
  
  def read_scheme_dir
    Dir.chdir(@scheme_dir) do
      
      begin
        Dir.glob("*.yml")
      rescue StandardError
        abort(read_error_message(scheme_dir))
      end
    end
  end

  def read_template_dir
    Dir.chdir(@template_dir) do
      
      begin
        Dir.glob("**/*.erb")
      rescue StandardError
        abort(read_error_message(@template_dir))
      end
    end
  end

  def read_template_file(template_file)
    template_file = @template_dir + "/#{template_file}" 
     
    begin
      File.open(template_file).read
    rescue StandardError
       abort(read_error_message(template_file))
    end
  end

  def parse_template_files(scheme_data)

    # Define ERB vars
    scheme = scheme_data["scheme"]
    author = scheme_data["author"]
    slug = slug(scheme_data["scheme"])
    uuid = SecureRandom.uuid
    base = {}
    
    [
      "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0A", "0B", 
      "0C", "0D", "0E", "0F"
    ].each do |key|
      hex = scheme_data["base" + key];
      base[key] = {
        "hex" => hex,
        "dhex" => to_dhex(hex),
        "rgb" => to_rgb(hex),
        "srgb" => to_srgb(hex)
      }
    end

    read_template_dir.each do |template_file|
      puts "  - " + template_file
      
      template_contents = read_template_file(template_file)
      parsed = ERB.new(template_contents)

      dir_name = File.dirname(template_file);
      file_name = File.basename(template_file, ".erb");
      scheme_name = slug(scheme)

      make_dir("#{@output_dir}/#{dir_name}")
      
      output_file = File.open(
        "#{@output_dir}/#{dir_name}/base16-#{scheme_name}.#{file_name}",
        "w"
      ) 
      output_file.write parsed.result(binding)
    end

  end
  
  def make_dir(name)
    if FileTest::directory?(name) 
      return
    end
    Dir::mkdir(name)
  end
  
  def slug(string)
    string.downcase.strip.gsub(' ', '.').gsub(/[^\w-]/, '')
  end
  
  def to_dhex(hex)
    hex.split(//).map {|char| char + char}.join
  end
  
  def to_rgb(hex)
    hex.scan(/../).map {|color| color.to_i(16)}
  end
  
  def to_srgb(hex)
    hex.scan(/../).map {|color| color.to_i(16).to_f / 255 }
  end
  
  def read_error_message(file)
    "Error reading #{file}"
  end

end

