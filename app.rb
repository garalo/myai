require 'sinatra'
require 'securerandom'
require 'net/http'
require 'json'
require 'uri'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'dotenv/load'
require 'openssl'


# Markdown ve Syntax Highlighting için Renderer Tanımlama
class HTMLWithPygments < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet # Rouge ile kod renklendirme desteği
end

 # ✅ Markdown'ı HTML'e çeviren fonksiyon
def markdown_to_html(text)
  renderer = HTMLWithPygments.new(
    hard_wrap: true,
    filter_html: false # HTML etiketlerine izin ver
  )

  options = {
    fenced_code_blocks: true, # ``` ile kod bloklarını destekle
    autolink: true, # Otomatik link algılama
    tables: true, # Markdown tablolarını destekle
    disable_indented_code_blocks: true # Girintili kod bloklarını kapat
  }

  markdown = Redcarpet::Markdown.new(renderer, options)
  markdown.render(text)
end

enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || 'abcedf01234567890123456789abcdef01234567890123456789abcdef012345'

api_key = ENV['GEMINI_TOKEN']
url = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent')

before do
  session[:chat_history] ||= []
end

get '/' do
  erb :index
end

post '/generate' do
  text = params['text']
  if text.nil? || text.empty?
     erb :error, locals: { message: 'Lütfen bir metin girin.' }
  end

  headers = {
    'Content-Type' => 'application/json',
     'Accept' => 'application/json'
  }
  data = {
    'contents' => [
      {
        'parts' => [
          {
            'text' => text
          }
        ]
      }
    ]
  }

  begin
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Yerel sertifika hatalarını önlemek için eklendi
    http.open_timeout = 5
    http.read_timeout = 20

    request = Net::HTTP::Post.new("#{url.path}?key=#{api_key}", headers)
    request.body = data.to_json

    response = http.request(request)

    if response.code != '200'
      warn "[DEBUG] Gemini HTTP #{response.code}: #{response.body[0..400]}"
      erb :error, locals: { message: "HTTP hatası: #{response.code} - #{response.body[0..400]}" }
    else
      json_response = JSON.parse(response.body, symbolize_names: true)

      begin
        @text = text
        @generated_text = json_response[:candidates][0][:content][:parts][0][:text]
        
        # Save to history
        session[:chat_history] << {
          id: SecureRandom.uuid,
          prompt: @text,
          response: @generated_text,
          timestamp: Time.now.strftime("%H:%M")
        }
        # Keep only last 20 chats
        session[:chat_history] = session[:chat_history].last(20)

        erb :result
      rescue KeyError, IndexError, TypeError => e
        erb :error, locals: { message: "Yanıt verisi beklenen formatta değil: #{e}" }
      end
    end
  rescue Net::HTTPError => e
     erb :error, locals: { message: "HTTP hatası: #{e}" }
  rescue StandardError => e
     erb :error, locals: { message: "İstek hatası: #{e}" }
  rescue Exception => e
     erb :error, locals: { message: "Beklenmedik hata: #{e}" }
  end
end

get '/history/:id' do
  @chat = session[:chat_history].find { |c| c[:id] == params[:id] }
  if @chat
    @text = @chat[:prompt]
    @generated_text = @chat[:response]
    erb :result
  else
    erb :error, locals: { message: "Geçmiş konuşma bulunamadı." }
  end
end

post '/history/clear' do
  session[:chat_history] = []
  redirect '/'
end
