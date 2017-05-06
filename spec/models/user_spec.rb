require 'models/user'

describe User do
  describe 'Validations' do
    it 'should not be valid without a twitter_id' do
      user = User.new(
        twitter_id: '',
        token:      'XYZ',
        secret:     '123RTY',
        username:   'simonfl3tcher',
        name:       'Simon Fletcher',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid without a token' do
      user = User.new(
        twitter_id: '123',
        token:      '',
        secret:     '123RTY',
        username:   'simonfl3tcher',
        name:       'Simon Fletcher',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid without a secret' do
      user = User.new(
        twitter_id: '123',
        token:      'XZY',
        secret:     '',
        username:   'simonfl3tcher',
        name:       'Simon Fletcher',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid without a username' do
      user = User.new(
        twitter_id: '123',
        token:      'XYZ',
        secret:     '123RTY',
        username:   '',
        name:       'Simon Fletcher',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid without a name' do
      user = User.new(
        twitter_id: '123',
        token:      'XYZ',
        secret:     '123RTY',
        username:   'simonfl3tcher',
        name:       '',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid without a image_url' do
      user = User.new(
        twitter_id: '123',
        token:      'XYZ',
        secret:     '123RTY',
        username:   'simonfl3tcher',
        name:       'Simon Fletcher',
        image_url:  ''
      )
      expect(user.valid?).to eq(false)
    end

    it 'should not be valid when twitter_id exists already' do
      attributes = {
        twitter_id: '123',
        token:      'XYZ',
        secret:     '123RTY',
        username:   'simonfl3tcher',
        name:       'Simon Fletcher',
        image_url:  'https://simonfl3tcher.com'
      }

      User.create(attributes)
      user = User.new(attributes)
      expect(user.valid?).to eq(false)
    end

    it 'should be valid with all the fields completed' do
      user = User.new(
        twitter_id: '123',
        name:       'Simon Fletcher',
        username:   'simonfl3tcher',
        token:      '123',
        secret:     '123132123',
        image_url:  'https://simonfl3tcher.com'
      )
      expect(user.valid?).to eq(true)
    end
  end

  describe 'Nested Attributes' do
    it 'should be valid with nested feeds' do
      user = User.new(
        twitter_id: '123',
        name:       'Simon Fletcher',
        username:   'simonfl3tcher',
        token:      '123',
        secret:     '123132123',
        image_url:  'https://simonfl3tcher.com',
        feeds_attributes: [
          { name: '123', type: 'search' }
        ]
      )
      expect(user.valid?).to eq(true)
    end

    it 'should not be valid if a nested feed is invalid' do
      user = User.new(
        twitter_id: '123',
        name:       'Simon Fletcher',
        username:   'simonfl3tcher',
        token:      '123',
        secret:     '123132123',
        image_url:  'https://simonfl3tcher.com',
        feeds_attributes: [
          { name: '123' }
        ]
      )
      expect(user.valid?).to eq(false)
    end
  end
end
