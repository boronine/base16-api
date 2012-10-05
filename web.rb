require 'sinatra'
require "securerandom"
require "erb"

require './base16'

get '/:temp' do
  temp = params[:temp]
  if temp == 'vim'
    template_file = 'vim/vim.erb'
  elsif temp == 'textmate'
    template_file = 'textmate/dark.tmTheme.erb'
  end
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

  if temp == 'vim'
    attachment "random.vim"
  elsif temp == 'textmate'
    attachment 'random.tmTheme'
  end

  uuid = '0'

  return parsed.result(binding)
end
