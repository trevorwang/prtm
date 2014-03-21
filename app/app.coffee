express = require 'express'
passport = require 'passport'
Config = require './config'
Router = require './routes'
logger = require './logger'

app = express()

config = new Config app, express, passport
config.init()

# configure app's router with passport
router = new Router app, passport
router.route()

port = app.get('port')
app.listen port
logger.debug "Server is started on #{port}"
