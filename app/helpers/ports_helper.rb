module PortsHelper

  def suggest_helper
    require 'net/http'
    count = 0
      open('ports.out', 'w') { |f|
        ('aaa'..'zzz').to_a.each do |i|
          if count >= 7134
            url = URI.parse("http://www.vesseltracker.com/app?component=%24VesseltrackerSuggest.%24XTile&page=RoutingVD&service=xtile&sp=#{i}")
            req = Net::HTTP::Get.new(url.to_s)
            res = Net::HTTP.start(url.host, url.port) {|http|
              http.request(req)
            }
            response = res.body.mb_chars
            starts = '\['
            ends = '\]'
            formatted_response = response[/#{starts}(.*?)#{ends}/m, 1]
            f << formatted_response
          end
          puts count += 1
        end
      }
  end

  def generate_portslist
    bson = Port.only(:name, :nationality, :portId, :lat, :lon)
    json_response = bson.to_a.to_json.to_s
    json_response = json_response.gsub('","nationality":"', ' - ')
    json_response = json_response.gsub('name', 'value')
    json_response = json_response.gsub(/{(.*?)lat/m, '{"lat')

    open('portslist.json', 'w') do |f|
      f << json_response
    end
  end

end
