describe Api do
  before(:each) do
    @user = User.create(
      twitter_id: '134324123',
      token:      '1231241',
      secret:     '1231241',
      username:   'simonfl3tcher',
      name:       'Andy Blogg',
      image_url:  'http://simonfl3tcher.com'
    )
    @user.feeds << Feed.new(name: 'YOLO', type: 'search')
  end

  describe 'with a valid JWT Token' do
    before(:each) do
      header 'Authorization',
             "Bearer #{create_jwt_token(@user.id.to_s, @user.username)}"
    end

    describe 'GET /users/:id/feeds/:feed_id' do
      before(:each) do
        service_obj = double(
          run: [
            {
              created_at: 'Fri May 05 22:12:35 +0000 2017',
              id:         359_834_923_843_423,
              id_str:     ' 359834923843423',
              text:       'YOLO'
            }
          ]
        )
        allow(TwitterService).to receive(:new).and_return(service_obj)
      end

      it 'should return the single feed for the user' do
        get "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(
          JSON.parse(last_response.body)[0]['text']
        ).to eq('YOLO')
      end

      it 'should return 404 if feed does not exist' do
        get "/users/#{@user.id}/feeds/123"

        expect(last_response.status).to eq(404)
      end
    end

    describe 'POST /users/:id/feeds' do
      it 'should create a feed for the user' do
        post "/users/#{@user.id}/feeds", {
          feed: {
            name: '#golang',
            type: 'search'
          }
        }, format: 'json'

        expect(last_response.status).to eq(201)
        expect(
          JSON.parse(last_response.body)['data']['attributes']['name']
        ).to eq('#golang')
      end

      it 'should create a list feed with users saved' do
        post "/users/#{@user.id}/feeds", {
          feed: {
            name: 'TECH',
            type: 'list',
            users: %w[simonfl3tcher TechCrunch]
          }
        }, format: 'json'

        expect(last_response.status).to eq(201)
        expect(
          JSON.parse(last_response.body)['data']['attributes']['users']
        ).to eq(%w[simonfl3tcher TechCrunch])
      end

      it 'should return 400 if the feed is not valid' do
        expected_response = {
          'status' => 400,
          'title'  => 'Feed failed to be created',
          'errors' => {
            'name' => ["can't be blank"],
            'type' => ["can't be blank", 'is not included in the list']
          }
        }
        post "/users/#{@user.id}/feeds", {
          feed: { name: '', type: '' }
        }, format: 'json'

        expect(last_response.status).to eq(400)
        expect(
          JSON.parse(last_response.body)
        ).to eq(expected_response)
      end
    end

    describe 'PUT /users/:id/feeds/:feed_id' do
      it 'should update a single feed for the user' do
        put "/users/#{@user.id}/feeds/#{@user.feeds.first.id}", {
          feed: {
            name: 'TOLO',
            type: 'search'
          }
        }, format: 'json'

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(
          JSON.parse(last_response.body)['data']['attributes']['name']
        ).to eq('TOLO')
      end

      it 'should update a list feed with users saved' do
        put "/users/#{@user.id}/feeds/#{@user.feeds.first.id}", {
          feed: {
            name: 'TOLO',
            type: 'list',
            users: %w[simonfl3tcher TechCrunch]
          }
        }, format: 'json'

        expect(last_response.status).to eq(200)
        expect(
          JSON.parse(last_response.body)['data']['attributes']['users']
        ).to eq(%w[simonfl3tcher TechCrunch])
      end

      it 'should return 404 is the feed does not exist' do
        put "/users/#{@user.id}/feeds/123", {
          feed: {
            name: 'TOLO',
            type: 'search'
          }
        }, format: 'json'

        expect(last_response.status).to eq(404)
      end

      it 'should return 400 if the feed is invalid' do
        expected_response = {
          'title'  => 'Feed failed to be updated',
          'status' => 400,
          'errors' => {
            'name' => ["can't be blank"],
            'type' => ["can't be blank", 'is not included in the list']
          }
        }
        put "/users/#{@user.id}/feeds/#{@user.feeds.first.id}", feed: {
          name: '',
          type: ''
        }

        expect(last_response.status).to eq(400)
        expect(
          JSON.parse(last_response.body)
        ).to eq(expected_response)
      end
    end

    describe 'DELETE /users/:id/feeds/:feed_id' do
      it 'should delete a single feed for the user' do
        @user.feeds << Feed.new(name: 'TOLO', type: 'search')

        expect(@user.feeds.count).to eq(2)

        delete "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

        expect(@user.reload.feeds.count).to eq(1)
        expect(last_response.status).to eq(204)
      end

      it 'should not delete a feed that does not exist' do
        expect(@user.feeds.count).to eq(1)

        delete "/users/#{@user.id}/feeds/123923423"

        expect(@user.reload.feeds.count).to eq(1)
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'without a JWT token' do
    describe 'GET /users/:id/feeds/:feed_id' do
      it 'should return 401 status code' do
        get "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(last_response.status).to eq(401)
      end
    end

    describe 'POST /users/:id/feeds' do
      it 'should return 401 status code' do
        post "/users/#{@user.id}/feeds", {
          feed: {
            name: '#golang',
            type: 'search'
          }
        }, format: 'json'

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(last_response.status).to eq(401)
      end
    end

    describe 'PUT /users/:id/feeds' do
      it 'should return 401 status code' do
        put "/users/#{@user.id}/feeds/#{@user.feeds.first.id}", {
          feed: {
            name: 'TOLO',
            type: 'list',
            users: %w[simonfl3tcher TechCrunch]
          }
        }, format: 'json'

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(last_response.status).to eq(401)
      end
    end

    describe 'DELETE /users/:id/feeds/:' do
      it 'should return 401 status code' do
        delete "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

        expect(last_response.content_type).to eq('application/vnd.api+json')
        expect(last_response.status).to eq(401)
      end
    end
  end
end
