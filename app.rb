require 'sinatra'
require 'RMagick'
require 'digest/sha1'

get '/:color/:size/:text.png' do
  color, text, size = params['color'].downcase, params['text'].upcase[0, 2], params['size'].to_i

  # Hex codes
  color = "##{color}" if color.length == 6 && color =~ /\A[a-f0-9]+\z/

  canvas = Magick::Image.new(size, size){ self.background_color = color }
  canvas.format = 'png'
  gc = Magick::Draw.new
  gc.pointsize = size / 2
  gc.font = File.join(File.dirname(__FILE__), 'lib', 'fonts', 'Helvetica.ttf')
  gc.gravity = Magick::CenterGravity
  gc.annotate(canvas, 0,0,0,0, text) {
    self.fill = 'white'
  }

  content_type 'image/png'
  cache_control :public, :must_revalidate, max_age: (365 * 24 * 60 * 60)
  etag Digest::SHA1.hexdigest "#{text}#{color}#{size}"
  canvas.to_blob
end
