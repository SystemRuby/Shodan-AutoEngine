require 'optparse'
require 'shodanz' 
require 'colorize'

class Program
  def initialize
    @data = { 
      API_KEY: "YOUR_API_KEY",
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
      STDERR.puts("Error: #{standart_error}".colorize(:red))
      return
    end
  end

  def save_output(output)
    begin
      File.open(@data[:output], "a+") do |file_man|
        file_man.puts(output)
      end
    rescue StandardError => standart_error
      STDERR.puts("Error: #{standart_error}".colorize(:red))
      return
    end
  end

  def print_help
    help_text <<-'HELP'
Kullanım: ruby shodan.rb [Options]

Opsiyonlar:
  -q, --query QUERY: No Search in Shodan Query Data
  -o, --output OUTPUT: File where query results will be recorded
  -p, --page PAGE: Number of Pages to Search in Shodan
  -k, --key API_KEY: API Key Data to Use When Searching Shodan
  -h, --help: Parameter that Prints the Help Message on the Screen
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
      STDERR.puts("Error: #{arg_error}".colorize(:red))
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
