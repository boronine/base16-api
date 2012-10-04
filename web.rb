require 'sinatra'
require "securerandom"
require "erb"

require 'base16'

get '/vim' do
  template_file = 'vim/vim.erb'
  scheme_data = {
    "base00" => "151515",
    "base01" => "202020",
    "base02" => "303030",
    "base03" => "505050",
    "base04" => "b0b0b0",
    "base05" => "d0d0d0",
    "base06" => "e0e0e0",
    "base07" => "f5f5f5",
    "base08" => "ac4142",
    "base09" => "d28445",
    "base0A" => "f4bf75",
    "base0B" => "90a959",
    "base0C" => "75b5aa",
    "base0D" => "6a9fb5",
    "base0E" => "aa759f",
    "base0F" => "8f5536"
  }
  scheme_data = params
  theme = Theme.new
  # Define ERB vars
  scheme = 'Random'
  author = 'HUSL'
  slug = theme.slug(scheme)
  base = {}
  [
    "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0A", "0B", 
    "0C", "0D", "0E", "0F"
  ].each do |key|
    hex = scheme_data['base' + key];
    base[key] = {
      "hex" => hex,
      "dhex" => theme.to_dhex(hex),
      "rgb" => theme.to_rgb(hex),
      "srgb" => theme.to_srgb(hex)
    }
  end
  template_contents = theme.read_template_file(template_file)
  parsed = ERB.new(template_contents)

  attachment "random.vim"
  return parsed.result(binding)
end
