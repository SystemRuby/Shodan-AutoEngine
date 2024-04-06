require 'optparse' # Parser İçin Gerekli Kütüphane
require 'net/ssh' # SSH Clienti İçin Gerekli Kütüphane
require 'shodanz' # Shodan Arama Motoru İçin Gerekli Kütüphane
require 'highline' # Güvenli Girdi (Input) Almak İçin Gerekli Kütüphane
require 'colorize' # Çıkrı Renklendirmesi İçin Gerekli Kütüphane

class Program
  def initialize
    @data = { # Verilerin Saklanacağı Liste Hash (Sözlük)
      API_KEY: "pHHlgpFt8Ka3Stb5UlTxcaEwciOeF2QM", # API Anahtarı Çift Tırnak İçinde Verilmelidir
      output: 'output.txt', # Çıktı Kaydı İçin Default Dosya İsmi
      page: 1, # İstek Atılacak Sayfa Sayısı İçin Default Değer (0'dan 1'e Kadar)
    }
  end

  def shodan_client(query_text, query_page) # Sorgu Değerini (query_text) Ve İstek Atılacak Sayfa Sayısını (query_page) Alan Fonksiyon
    begin # İstek Atılırken Olası Hatanın Yakalanması İçin Begin-Rescue (Try-Catch) Bloğu
      shodan_result = @shodan_client.host_search(query_text, page: query_page) # Shodan'da Sorguyu Yapan Kod
      puts("Sayfa Numarası: #{query_page}".colorize(:blue))

      if shodan_result # Eğer Bir Dönüt Varsa Yapılacak İşlemlerin Bloğu
        shodan_result['matches'].each do |match_result| # Dönen Çıktı İçerisinde For (Each) Döngüsü Oluşturur
          save_output(match_result['ip_str'])
          STDOUT.puts("IP: #{match_result['ip_str']}".colorize(:red)) # Çıktı İçinden IP Verisini Ekrana Yazdırır
        end
      end
    rescue StandardError => standart_error # İstek Sırasında Bir Hata Alınırsa Ekrana Yansıtıp Döngüyü Sonlandıracak Olan Blok
      STDERR.puts("Hata: #{standart_error}".colorize(:red))
      return # Fonksiyonun Bitirilmesi
    end
  end

  def save_output(output) # Çıktı Kaydı İçin Gerekli Fonksiyon
    begin # Hata Yakalama Bloğu
      File.open(@data[:output], "a+") do |file_man| # Dosyayı Açıp Veriyi Ekleyen Döngü
        file_man.puts(output) # Dosyayı Açıp Veriyi Ekleyen Metod
      end
    rescue StandardError => standart_error
      STDERR.puts("Hata: #{standart_error}".colorize(:red))
      return
    end
  end

  def print_help # Yardım Mesajını Ekrana Basan Fonksiyon
    help_text <<-'HELP' # Çoklu Metin Formatı
Kullanım: ruby shodan.rb [Opsiyonlar]

Opsiyonlar:
  -q, --query QUERY: Shodan'da Arama Yapılacak Sorgu Verisi
  -o, --output OUTPUT: Sorgu Sonuçlarının Kayıt Altına Alınacağı Dosya
  -p, --page PAGE: Shodan'da Arama Yapılacak Sayfa Sayısı
  -k, --key API_KEY: Shodan'da Arama Yaparken Kullanılacak API Anahtar Verisi
  -h, --help: Yardım Mesajını Ekrana Basan Parametre
    HELP
  end

  def parser_opts
    begin
      OptionParser.new do |parser| # Parser Etkileşimini Kuran Döngü ("-q, -o" vb.)
        parser.on("-q", "--query QUERY") { |query| @data[:query] = query } # -q, --query
        parser.on("-o", "--output OUTPUT") { |output| @data[:output] = output } # -o, --output
        parser.on("-p", "--page PAGE", Integer) { |page| @data[:page] = page } # -p, --page
        parser.on("-k", "--key API_KEY") { |api_key| @data[:API_KEY] = api_key } # -k, --key
        parser.on("-h", "--help") { print_help; exit! } # -h
      end.parse! # Parse Edilmesi
    rescue ArgumentError => arg_error
      STDERR.puts("Hata: #{arg_error}".colorize(:red)) # Hata Alınırsa
      print_help
      exit!
    end
  end

  def main
    parser_opts # Parse Verisi Çağırımı
    @shodan_client = Shodanz.client.new(key: @data[:API_KEY]) # Shodan Arama Motorunu İçin Nesne Oluşturumu Ve API Tanımlama

    if @data[:query]
      (0..@data[:page]).each do |value| # 0'dan Başlayarak Kullanıcının Verdiği Sayfa Sayısı
        shodan_client(@data[:query], value) # Kadar Fonksiyonun Aldığı
        value += 1 # Sayfa Değerini Arttıran Kod
      end
    else
      print_help
      exit!
    end
  end
end

exploit = Program.new # Sınıfın Çağırılması
exploit.main # Main Fonksiyonunun Çağırılması