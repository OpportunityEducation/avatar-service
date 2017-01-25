require 'sinatra'
require 'newrelic_rpm'
require 'rmagick'
require 'digest/sha1'

GC::Profiler.enable

get '/' do
  File.read(File.join('public', 'index.html'))
end

['', 'v2/', 'v3/'].each do |prefix|
  get "/#{prefix}:color/:size/:text.png" do
    color, text, size = params['color'].downcase, params['text'].upcase[0, 2], params['size'].to_i

    # Hex codes
    color = "##{color}" if color.length == 6 && color =~ /\A[a-f0-9]+\z/i

    begin
      canvas = Magick::Image.new(size, size){ self.background_color = color; self.depth = 8; }
    rescue ArgumentError
      canvas = Magick::Image.new(size, size){ self.background_color = 'black' }
    end

    canvas.format = 'png'
    gc = Magick::Draw.new
    gc.pointsize = (size / 2).ceil
    gc.font = File.join(File.dirname(__FILE__), 'lib', 'fonts', 'Roboto-Regular.ttf')
    gc.gravity = Magick::CenterGravity
    gc.annotate(canvas, 0,0,0,0, text) {
      self.fill = 'white'
    }

    content_type 'image/png'
    cache_control :public, :must_revalidate, max_age: (365 * 24 * 60 * 60)
    etag Digest::SHA1.hexdigest "#{text}#{color}#{size}"
    canvas.to_blob
  end
end
