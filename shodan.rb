require 'optparse'
require 'net/ssh'
require 'shodanz' 
require 'highline'
require 'colorize'

class Program
  def initialize
    @data = { 
      API_KEY: "pHHlgpFt8Ka3Stb5UlTxcaEwciOeF2QM",
      output: 'output.txt',
      page: 1,
    }
  end

  def shodan_client(query_text, query_page)
    begin
      shodan_result = @shodan_client.host_search(query_text, page: query_page)
      puts("Sayfa Numarası: #{query_page}".colorize(:blue))

      if shodan_result
        shodan_result['matches'].each do |match_result|
          save_output(match_result['ip_str'])
          STDOUT.puts("IP: #{match_result['ip_str']}".colorize(:red))
        end
      end
    rescue StandardError => standart_error
      STDERR.puts("Hata: #{standart_error}".colorize(:red))
      return
    end
  end

  def save_output(output)
    begin
      File.open(@data[:output], "a+") do |file_man|
        file_man.puts(output)
      end
    rescue StandardError => standart_error
      STDERR.puts("Hata: #{standart_error}".colorize(:red))
      return
    end
  end

  def print_help
    help_text <<-'HELP'
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
      OptionParser.new do |parser| 
        parser.on("-q", "--query QUERY") { |query| @data[:query] = query } # -q, --query
        parser.on("-o", "--output OUTPUT") { |output| @data[:output] = output } # -o, --output
        parser.on("-p", "--page PAGE", Integer) { |page| @data[:page] = page } # -p, --page
        parser.on("-k", "--key API_KEY") { |api_key| @data[:API_KEY] = api_key } # -k, --key
        parser.on("-h", "--help") { print_help; exit! } # -h
      end.parse!
    rescue ArgumentError => arg_error
      STDERR.puts("Hata: #{arg_error}".colorize(:red))
      print_help
      exit!
    end
  end

  def main
    parser_opts
    @shodan_client = Shodanz.client.new(key: @data[:API_KEY])

    if @data[:query]
      (0..@data[:page]).each do |value|
        shodan_client(@data[:query], value)
        value += 1 
      end
    else
      print_help
      exit!
    end
  end
end

exploit = Program.new
exploit.main
