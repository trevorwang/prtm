logger = require '../logger'

class Router
  constructor: (@app, @passport)->

  # express router
  express: ->
    @app.get "/", (req, res) ->
      # if req.user
      #   logger.data "\nSessionID : #{req.sessionID}",
      #   "\nCookies : ", req.cookies, "\nSession : ", req.session
      return res.render 'index'
      # else res.redirect '/login'

    @app.get "/login", (req, res) ->
      res.render 'login'

    @app.post '/login',
    @passport.authenticate('local', failureRedirect: '/login'), (req, res) ->
      logger.debug "user logged in successfully!"
      res.redirect '/'

  route: ->
    @express()

module.exports = Router
