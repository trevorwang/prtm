logger = require '../logger'
#Exchanger = require './exchange'
#exchanger = new Exchanger

class Router
  constructor: (@app, @passport)->
    @hello = 'world'
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

    # @app.post '/login',
    # @passport.authenticate('local', failureRedirect: '/login'), (req, res) ->
    #   logger.debug "user logged in successfully!"
    #   res.redirect '/'

    @app.get '/prt', (req,res) ->
#      exchanger.getEmails(req, res)

  route: ->
    @express()
    # @exchanger.getEmails()

module.exports = Router
