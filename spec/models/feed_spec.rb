require 'models/feed'

describe Feed do
  describe "Validations" do
    it "should not be valid without a name" do
      feed = Feed.new(
        :name => "",
        :type => "search"
      )
      expect(feed.valid?).to eq(false)
    end

    it "should be valid with a name and a type" do
      feed = Feed.new(
        :name => "Simon Fletcher",
        :type => "search"
      )
      expect(feed.valid?).to eq(true)
    end
  end
end
