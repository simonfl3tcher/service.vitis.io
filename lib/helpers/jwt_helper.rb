require 'jwt'

module JWTHelper
  def create_jwt_token(user_id, username)
    JWT.encode payload(user_id, username), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(user_id, username)
    {
      exp:    Time.now.to_i + 60 * 60,
      iat:    Time.now.to_i,
      iss:    ENV['JWT_ISSUER'],
      scopes: %w[create_feed update_feed delete_feed view_feed],
      user:   {
        id: user_id,
        username: username
      }
    }
  end

  def process_request(req, scope, potential_user)
    scopes, user = req.env.values_at :scopes, :user
    username = user['username']
    user_id  = user['id']

    if scopes.include?(scope) &&
       potential_user.id.to_s == user_id && potential_user.username == username
      yield req
    else
      status 403
    end
  end
end
