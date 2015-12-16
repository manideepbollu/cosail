class TestingController < ApplicationController

  respond_to :json

  def new

    require 'net/http'
    url = URI.parse("http://www.vesseltracker.com/app?component=%24VesseltrackerSuggest.%24XTile&page=RoutingVD&service=xtile&sp=#{params[:sp]}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    @response = res.body
    starts = '\['
    ends = '\]'
    respond_with('['+@response[/#{starts}(.*?)#{ends}/m, 1]+']')
  end
end
