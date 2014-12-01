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

app.use require('coffee-middleware')
  src: path.join app.PUBLIC
  bare: true
  force: true
  encodeSrc: false # way cool src map feature, but easier to debug js

app.use express.static app.PUBLIC # static file server

# Controllers

app.get '/', (req, res) ->
  res.render 'home'

# Server

http = app.listen app.PORT, '0.0.0.0', ->
  console.log 'Listening on '+ JSON.stringify http.address()

  # add websocket support
  server = engine.attach http
  players = []
  player_count = 0
  rooms = []
  room_count = 0

  broadcast = (players, exclude_id, msg) ->
    for player in players when player.id isnt exclude_id
      player.socket.send JSON.stringify msg

  server.on 'connection', (socket) ->
    players[++player_count] = player =
      new Player id: player_count, name: "player#{(player_count-1)%2+1}", socket: socket
    if rooms[room_count]?.players.length < 2 # not full
      room = rooms[room_count]
    else
      rooms[++room_count] = room =
        new Room id: room_count
    room.players.push player
    player.room_id = room.id
    socket.send JSON.stringify player: id: player.id, name: player.name
    socket.on 'message', (data) ->
      console.log data
      data = JSON.parse data
      if data.pm? # player move
        [player_id, x, y] = data.pm
        player = players[player_id]
        broadcast rooms[player.room_id].players, player.id, pm: [player.name, x, y]
      else if data.pf? # player facing
        [player_id, f] = data.pf
        player = players[player_id]
        broadcast rooms[player.room_id].players, player.id, pf: [player.name, f]
      else if data.pl? # player light
        [player_id, l] = data.pl
        player = players[player_id]
        broadcast rooms[player.room_id].players, player.id, pl: [player.name, l]
      else if data.pv? # monster visibility
        [player_id, v] = data.pv
        player = players[player_id]
        broadcast rooms[player.room_id].players, player.id, pv: [player.name, v]
      else if data.pw? # player win
        [player_id] = data.pw
        player = players[player_id]
        broadcast rooms[player.room_id].players, player.id, pw: [player.name]

    socket.on 'close', ->
      delete players[player.id]

class Player
  constructor: ({@id, @name, @room_id, @socket}) ->

class Room
  constructor: ({@id, @players}) ->
    @players ||= []
