express = require 'express'
jade    = require 'jade'
stylus  = require 'stylus'
nib     = require 'nib'
path    = require 'path'
engine  = require 'engine.io'

app = express()
app.disable 'x-powered-by'

app.PORT   = 3000
app.APP    = path.join __dirname, path.sep
app.VIEWS  = path.join app.APP, 'views', path.sep
app.PUBLIC = path.join app.APP, 'public', path.sep

# Models

# Views

app.set 'views', app.VIEWS
app.set 'view engine', 'jade'
app.locals.pretty = true
app.use stylus.middleware src: path.join(app.PUBLIC), compile: (str, path) ->
  stylus(str).set('filename', path).use nib()

app.use require('connect-coffee-script')
  src: path.join app.PUBLIC
  dest: path.join app.PUBLIC
  bare: true
  force: true

app.use express.static app.PUBLIC # static file server

# Controllers

app.get '/', (req, res) ->
  res.render 'home'

# Server

http = app.listen app.PORT, '0.0.0.0', ->
  console.log 'Listening on '+ JSON.stringify http.address()

  # add websocket support
  server = engine.attach http
  server.on 'connection', (socket) ->
    timer = undefined
    socket.on 'close', -> clearTimeout timer
    broadcast = ->
      socket.send JSON.stringify 'hi'
      timer = setTimeout broadcast, 3000 # repeat every 3 sec
    broadcast() # kick-start immediately upon connection

