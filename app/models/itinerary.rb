class Itinerary
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Geospatial
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  DAYNAME = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  belongs_to :user
  delegate :name, to: :user, prefix: true
  delegate :first_name, to: :user, prefix: true

  has_many :conversations, as: :conversable, dependent: :destroy

  # Details
  field :description
  field :num_people, type: Integer
  field :smoking_allowed, type: Boolean, default: false
  field :pets_allowed, type: Boolean, default: false
  field :price, type: Integer, default: 0
  field :days_at_sea, type: Integer, default: 0
  field :pink, type: Boolean, default: false
  field :round_trip, type: Boolean, default: false
  field :leave_date, type: DateTime
  field :return_date, type: DateTime
  field :daily, type: Boolean, default: false
  field :start_address, type: String
  field :end_address, type: String
  field :start_port_id, type: String
  field :end_port_id, type: String
  field :start_coords, type: String
  field :end_coords, type: String
  field :route_path, type: String


  # Cached user details (for filtering purposes)
  field :driver_gender
  field :verified

  slug :start_address, :end_address, reserve: %w(new)

  # default_scope -> { any_of({:leave_date.gte => Time.now.utc}, {:return_date.gte => Time.now.utc, round_trip: true}, { daily: true }) }

  validates :description, length: { maximum: 1000 }, presence: true
  validates :start_address, presence: true
  validates :end_address, presence: true
  validates :num_people, numericality: { only_integer: true, greater_than: 0, less_than: 10 }, allow_blank: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }
  validates :days_at_sea, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }
  validates :leave_date, timeliness: { on_or_after: -> { Time.now } }, on: :create
  validates :return_date, presence: true, if: -> { round_trip }

  validate :driver_is_female, if: -> { pink }
  validate :return_date_validator, if: -> { round_trip }

  def return_date_validator
    self.errors.add(:return_date,
                    I18n.t('mongoid.errors.messages.after',
                    restriction: leave_date.strftime(I18n.t('validates_timeliness.error_value_formats.datetime')))) if return_date && return_date <= leave_date
  end

  def driver_is_female
    self.errors.add(:pink, :driver_must_be_female) unless user.female?
  end

  before_create do
    self.driver_gender = user.gender
    self.verified = user.facebook_verified
    true
  end

  # after_create do
  #   begin
  #     # Resque.enqueue(FacebookTimelinePublisher, id) if share_on_facebook_timeline
  #   rescue Redis::CannotConnectError
  #   end
  # end

  def title
    [start_address, end_address].join ' - '
  end

  def to_s
     title || id
  end

  def static_map(width = 640, height = 360)
    URI.encode("http://maps.googleapis.com/maps/api/staticmap?size=#{width}x#{height}&scale=2&sensor=false&markers=color:green|label:B|#{end_coords}&markers=color:green|label:A|#{start_coords}&path=enc:#{route_path}")
  end

end
