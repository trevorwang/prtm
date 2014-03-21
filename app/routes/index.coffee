logger = require '../logger'
Prt = require '../models/prt'
prt = new Prt

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

    # @app.post '/login',
    # @passport.authenticate('local', failureRedirect: '/login'), (req, res) ->
    #   logger.debug "user logged in successfully!"
    #   res.redirect '/'

    @app.get '/prt', (req,res) ->
      Prt.find {}, (err, prts)->
        res.json prts

  route: ->
    @express()
    # @exchanger.getEmails()

module.exports = Router
