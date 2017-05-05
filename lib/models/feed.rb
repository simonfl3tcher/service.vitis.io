class Feed
  include Mongoid::Document
  field :name,             type: String
  field :type,             type: String
  field :search_parameter, type: String

  validates_presence_of :name
  validates_presence_of :type

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
