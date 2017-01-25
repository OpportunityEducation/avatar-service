require File.expand_path '../spec_helper.rb', __FILE__
require 'digest/sha1'

describe 'Avatar Service' do
  it 'should allow accessing the home page' do
    get '/'

    expect(last_response).to be_ok
  end

  context 'avatars' do
    let(:size)      { 400 }
    let(:initials)  { 'jr' }
    let(:path)      { "/v3/#{color}/#{size}/#{initials}.png" }

    before(:each) do
      get path
    end

    [['named color', 'red'], ['hex value', '7569af']].each do |type, color|
      context "#{type} (#{color})" do
        let(:color) { color }

        it 'should set the expires header' do
          expect(last_response.headers).to have_key('Cache-Control')
          expect(last_response.headers['Cache-Control']).to eq 'public, must-revalidate, max-age=31536000'
        end

        it 'should return the correct content type' do
          expect(last_response.headers).to have_key('Content-Type')
          expect(last_response.headers['Content-Type']).to eq 'image/png'
        end

        it 'should return the correct ETag' do
          expect(last_response.headers).to have_key('ETag')
          etag_color = color =~ /\A[a-f0-9]+\z/i ? "##{color}" : color
          expect(last_response.headers['ETag']).to eq "\"#{Digest::SHA1.hexdigest("#{initials.upcase}#{etag_color.downcase}#{size}")}\""
        end

        xit 'should match example image' do
          expect(Digest::MD5.hexdigest(last_response.body)).to eq Digest::MD5.hexdigest(File.binread(File.expand_path("../examples#{path}", __FILE__)))
        end
      end
    end

    context 'invalid color (blu)' do
      let(:color) { 'blu' }

      it 'should set the expires header' do
        expect(last_response.headers).to have_key('Cache-Control')
        expect(last_response.headers['Cache-Control']).to eq 'public, must-revalidate, max-age=31536000'
      end

      it 'should return the correct content type' do
        expect(last_response.headers).to have_key('Content-Type')
        expect(last_response.headers['Content-Type']).to eq 'image/png'
      end

      it 'should return the correct ETag' do
        expect(last_response.headers).to have_key('ETag')
        expect(last_response.headers['ETag']).to eq "\"#{Digest::SHA1.hexdigest("#{initials.upcase}#{color}#{size}")}\""
      end

      xit 'should match error image' do
        expect(Digest::MD5.hexdigest(last_response.body)).to eq Digest::MD5.hexdigest(File.binread(File.expand_path("../examples/black/400/jr.png", __FILE__)))
      end
    end
  end
end
