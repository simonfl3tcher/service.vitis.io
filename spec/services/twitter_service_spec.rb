require 'services/twitter_service'

describe TwitterService do
  before(:all) do
    @user = User.create(
      twitter_id: "134324123",
      token:      "1231241",
      secret:     "1231241",
      username:   "simonfl3tcher",
      name:       "Andy Blogg",
      image_url: "http://simonfl3tcher.com"
    )
    @feed1 = Feed.new(name: "timeline", type: "timeline")
    @feed2 = Feed.new(name: "YOLO", type: "search")
    @user.feeds << @feed1
    @user.feeds << @feed2
  end

  before(:each) do
    client_obj = double(
      :home_timeline => [
        {
          "created_at": "Fri May 05 22:12:35 +0000 2017",
          "id": 359834923843423,
          "id_str": " 359834923843423",
          "text": "YOLO",
        }
      ],
      :search => [
        {
          "created_at": "Fri May 05 22:12:35 +0000 2017",
          "id": 359834923843423,
          "id_str": " 359834923843423",
          "text": "OLLI",
        }
      ]
    )
    allow(Twitter::REST::Client).to receive(:new).and_return(client_obj)
  end

  describe "#run" do
    describe "timeline" do
      it "should return the timeline events if passed in a timeline feed" do
        expect(TwitterService.new(user: @user, feed: @feed1).run).to eq(
          [
            {
              "created_at": "Fri May 05 22:12:35 +0000 2017",
              "id": 359834923843423,
              "id_str": " 359834923843423",
              "text": "YOLO",
            }
          ]
        )
      end
    end

    describe "search" do
      it "should return tweets that match the search parameter" do
        expect(TwitterService.new(user: @user, feed: @feed2).run).to eq(
          [
            {
              "created_at": "Fri May 05 22:12:35 +0000 2017",
              "id": 359834923843423,
              "id_str": " 359834923843423",
              "text": "OLLI",
            }
          ]
        )
      end
    end
  end
end
