require 'sinatra'
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

api_key = ENV['GEMINI_TOKEN']
url = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent')

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
    # short sensible timeouts
    http.open_timeout = (ENV['GEMINI_OPEN_TIMEOUT'] || 5).to_i
    http.read_timeout = (ENV['GEMINI_READ_TIMEOUT'] || 20).to_i

    # Optionally skip SSL verification for local testing (insecure)
    if params['insecure'] == '1' || ENV['GEMINI_SKIP_CERT_VERIFY'] == 'true'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      warn "[WARN] SSL verification disabled for this request (insecure)"
    end

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
        @insecure_used = (params['insecure'] == '1' || ENV['GEMINI_SKIP_CERT_VERIFY'] == 'true')
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
