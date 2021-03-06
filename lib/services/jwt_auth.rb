class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if env['REQUEST_METHOD'] == 'OPTIONS'
    options    = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
    bearer     = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    payload,   = JWT.decode bearer, ENV['JWT_SECRET'], true, options


    env[:scopes]  = payload['scopes']
    env[:user]    = payload['user']

    @app.call(env)
  rescue JWT::DecodeError
    [
      401,
      { 'Content-Type' => 'application/vnd.api+json' },
      ['A token must be passed.']
    ]
  rescue JWT::ExpiredSignature
    [
      403,
      { 'Content-Type' => 'application/vnd.api+json' },
      ['The token has expired.']
    ]
  rescue JWT::InvalidIssuerError
    [
      403,
      { 'Content-Type' => 'application/vnd.api+json' },
      ['The token does not have a valid issuer.']
    ]
  rescue JWT::InvalidIatError
    [
      403,
      { 'Content-Type' => 'application/vnd.api+json' },
      ['The token does not have a valid "issued at" time.']
    ]
  end
end
