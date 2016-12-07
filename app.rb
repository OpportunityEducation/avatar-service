require 'sinatra'
require 'newrelic_rpm'
require 'digest/sha1'
require 'mini_magick'

get '/:color/:size/:text.png' do
  color, text, size = params['color'].downcase, params['text'].upcase[0, 2], params['size'].to_i

  # Hex codes
  color = "##{color}" if color.length == 6 && color =~ /\A[a-f0-9]+\z/

  image = MiniMagick::Tool::Convert.new do |convert|
    convert.merge! ['-background', color]
    convert.merge! ['-fill', 'white']
    convert.merge! ['-font', File.join(File.dirname(__FILE__), 'lib', 'fonts', 'Helvetica.ttf')]
    convert.merge! ['-size', "#{size}x#{size}"]
    convert.merge! ['-pointsize', size / 2]
    convert.merge! ['-gravity', 'center']
    convert << "label:#{text}"
    convert << "png:-"
  end

  cache_control :public, :must_revalidate, max_age: (365 * 24 * 60 * 60)
  etag Digest::SHA1.hexdigest "#{text}#{color}#{size}"
  content_type 'image/png'
  image
end
