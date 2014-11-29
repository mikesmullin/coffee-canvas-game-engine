define [
  'engine.io-client/engine.io'
], (eio) -> class Network
  connect: ->
    # TODO: implement my fancy binary xor comm protocol later
    myid = null

    address = window.location.href.split('/')[2].split(':')[0]
    socket = new eio.Socket 'ws://'+address+'/'
    socket.on 'open', ->
      socket.on 'message', (data) ->
        console.log data
        data = JSON.parse data
        if data.player?
          whoami = data.player.name
          myid = data.player.id
        else if data.pm?
          [player_name, x, y] = data.pm
          objects[player_name].x = x
          objects[player_name].y = y

      socket.on 'close', ->
