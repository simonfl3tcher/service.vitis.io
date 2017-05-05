class Feed
  FEED_TYPES=['timeline', 'search']

  include Mongoid::Document

  field :name,             type: String
  field :type,             type: String
  field :search_parameter, type: String

  validates_presence_of :name
  validates_presence_of :type
  validates_inclusion_of :type, in: FEED_TYPES

  embedded_in :user

  def jsonapi_response
    {
      data: {
        type: "feed",
        id: id.to_s,
        attributes: attributes,
        relationships: {
          user: user.attributes
        }
      }
    }.to_json
  end
end
