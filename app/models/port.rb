class Port
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Geospatial
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  # Details
  field :name, type: String
  field :portId, type: String
  field :nationality, type: String
  field :locode, type: String
  field :flagid, type: String
  field :lon
  field :lat

  def self.load_from_json(filename)
    data = ''
    f = File.open(filename, "r")
    f.each_line do |line|
      data += line
    end
    if Port.create(JSON.parse(data))
      puts 'Json is successfully loaded'
    else
      puts 'Loading failed!'
    end
  end

end
