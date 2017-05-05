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

    describe "type inclusion" do
      it "should be valid with a type of search" do
        feed = Feed.new(
          :name => "Simon Fletcher",
          :type => "search"
        )
        expect(feed.valid?).to eq(true)
      end

      it "should be valid with a type of timeline" do
        feed = Feed.new(
          :name => "Simon Fletcher",
          :type => "timeline"
        )
        expect(feed.valid?).to eq(true)
      end

      it "should be invalid if type is not search or timeline" do
        feed = Feed.new(
          :name => "Simon Fletcher",
          :type => "XYZ"
        )
        expect(feed.valid?).to eq(false)
      end
    end
  end
end
