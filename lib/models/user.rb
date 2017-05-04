class User
  include Mongoid::Document

  field :twitter_id,    type: String
  field :name,          type: String
  field :image_url,     type: String

  validates_presence_of :twitter_id
  validates_presence_of :name
  validates_presence_of :image_url

  embeds_many :feeds
  accepts_nested_attributes_for :feeds

  def jsonapi_response
    {
      data: {
        type: "users",
        id: id.to_s,
        attributes: attributes,
        relationships: {
          feeds: feeds.map { |f| { data: f.attributes } }
        }
      }
    }.to_json
  end
end
