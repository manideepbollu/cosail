class PortsController < ApplicationController
  def suggest
    data = ''
    f = File.open('portslist.json', "r")
    f.each_line do |line|
      data += line
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end

  def route
    require 'net/http'
    html_url = URI.parse("http://www.vesseltracker.com/en/RoutingVD.html?chosenNumberOfRoutes=ONE&fromPortId=#{params[:fport]}&speed=20&toPortId=#{params[:tport]}")
    html_req = Net::HTTP::Get.new(html_url.to_s)
    html_res = Net::HTTP.start(html_url.host, html_url.port) {|http|
      http.request(html_req)
    }
    @html_cookie = html_res['Set-Cookie']
    html_response = html_res.body.mb_chars

    starts = 'b\u003e '
    ends = '\u003cbr'
    formatted_distance = html_response[/#{starts}(.*?)#{ends}/m, 1]
    starts = 'Journey time:\u003c/b\u003e '
    net_distance = formatted_distance.delete(' nm').to_f
    duration = (net_distance/100)*24
    formatted_duration = (duration/24).to_i.to_s+' days, '+(duration%24).to_i.to_s+' hrs'
    final_hash = {distance: formatted_distance, duration: formatted_duration}

    xml_url = URI.parse('http://www.vesseltracker.com/app?component=%24RoutingOSMPolygone.%24XTile&page=RoutingVD&service=xtile')
    xml_req = Net::HTTP::Get.new(xml_url.to_s)
    xml_req['Cookie'] = @html_cookie
    xml_res = Net::HTTP.start(xml_url.host, xml_url.port) {|http|
      http.request(xml_req)
    }
    temp = Hash.from_xml(xml_res.body.mb_chars)
    @data = temp["data"]["sp"]
    @data.shift
    @data.pop

    final_array = []
    point_hash = {}
    iterator = false

    @data.reverse.each do |data|
      if !iterator
        point_hash = {}
        point_hash['lat'] = data.to_f
      else
        point_hash['lng'] = data.to_f
        final_array.push(point_hash)
      end
      iterator ^= true
    end

    final_hash['coords'] = final_array
    @data = final_hash.to_json

    respond_to do |format|
      format.json { render json: @data }
    end

  end
end
