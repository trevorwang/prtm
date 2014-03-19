path = require 'path'
mongoose = require 'mongoose'
promise = require 'express-promise'
LocalStrategy = require('passport-local').Strategy
User = require './models/user'
logger = require './logger'

class Config
  constructor: (@app, @express, @passport)->
    @dbUrl = 'mongodb://localhost/passport'
  init: ->
    mongoose.connect @dbUrl
    # MongoStore = require('connect-mongo')(@express)
    # @mongoStore = new MongoStore
    #   mongoose_connection: mongoose.connection
    #
    # @sessionOptions =
    #   key : 'connect.sid'
    #   secret : 'This is a secret for express'
    #   store : @mongoStore

    @configExpress()
    # @configPassport()

  # express configuration
  configExpress: ->
    @app.set 'port', process.env.PORT or 8080
    @app.set 'view engine', 'jade'
    @app.set 'views', path.join(__dirname, 'views')
    @app.use @express.static(path.join(__dirname, 'public'))
    @app.use @express.favicon()
    @app.use @express.logger "dev"
    @app.use @express.json()
    @app.use @express.urlencoded()
    @app.use @express.methodOverride()
    @app.use @express.cookieParser()
    @app.use @express.bodyParser()
    @app.use promise()
    # @app.use @express.session @sessionOptions
    # @app.use @passport.initialize()
    # @app.use @passport.session()
    @app.use @app.router
    # use error handler for development mode
    @app.use @express.errorHandler() if @app.get('env') is 'development'

  # passport configuration
  configPassport: ->
    @passport.use new LocalStrategy (username, password, done)->
      logger.debug "#{username} use #{password} to login"
      User.findOne "local.email":username, (err, user) ->
        return done err if err
        return done null,false unless user
        logger.d  ebug "find user : #{user}"
        if not user.validPassword password then return done null, false
        return done null, user

    @passport.serializeUser (user, done) ->
      logger.debug "serializeUser..."
      done(null, user._id)

    @passport.deserializeUser (id, done) ->
      logger.debug "deserializeUser : #{id}"
      User.findById id, (err, user) ->
        logger.warn err if err
        done err, user

module.exports = Config
