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

  index({ portId: 1 }, { unique: true, drop_dups: true, name: 'portId_index' })

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

  def self.eliminate_duplicates()
    seen = []
    Port.each do |port|
      if seen.include?(port.portId)
        port.delete
      else
        seen.push(port.portId)
        puts port.portId
      end
    end
    Port.save
  end

end
