require 'net/http'
require 'json'

def restGet(url)
  hostname = 'api.wmata.com'
  port = 443
  key = 'kfgpmgvfgacx98de9q3xazww'
  req = Net::HTTP::Get.new(url % {:key => key})
  req["Accept"] = 'application/json'
  resp = Net::HTTP.start(hostname, port,
                         :use_ssl => true) do |http|
    http.request(req)
  end

  data = resp.body
  json = JSON.parse(data)

  if json["statusCode"] == nil
    return json
  else
    raise "#{json}"
  end
end

stationlist = restGet("/Rail.svc/json/jStations?LineCode=OR&api_key=%{key}")
ballstoncode = nil
stationlist["Stations"].each_with_index do |item, idx|
  if item["Name"] == "Ballston"
    ballstoncode = item["Code"]
  end
end

stationpredictions = restGet("/StationPrediction.svc/json/GetPrediction/#{ballstoncode}?api_key=%{key}")

nextarrival = nil
stationpredictions["Trains"].each_with_index do |item, idx|
  if item["Min"] != "BRD" && item["Line"] == "OR" #Ignore trains that have already arrived
    nextarrival = item
  end
end

puts nextarrival
