# TODO: implement my fancy binary xor comm protocol later
define [
  'engine.io-client/dist/engine.io'
], (eio) -> class Network
  constructor: ({ @engine }) ->
    @socket = null
    @connected = false

  Connect: (cb) ->
    address = window.location.href.split('/')[2]
    @socket = new eio.Socket ''+(if window.location.protocol == 'https:' then 'wss' else 'ws')+'://'+address+'/'
    @socket.on 'open', =>
      @connected = true
      @socket.on 'message', (data) =>
        console.log 'recv: '+data
        data = JSON.parse data
        if data.player?
          whoami = data.player.name
          myid = data.player.id
          cb whoami, myid
        else
          @Receive data

      @socket.on 'close', ->

  @lastData = null
  Send: (data) ->
    @socket.send JSON.stringify data
    # console.debug 'sent: '+JSON.stringify data
    @lastData = data

  Receive: (data) =>
    if data.pm?
      [player_name, x, y] = data.pm
      for object in @engine.objects when object.renderer?.mesh_name is player_name
        dX = x - object.transform.position.x
        dY = y - object.transform.position.y
        if dX < 4 and dY < 4
          # double-check collider at close distances because of network latency; not perfect but better
          object.collider.Move @engine, x: dX, y: dY
        else
          # allow teleport long distances
          object.transform.position.x = x
          object.transform.position.y = y
    else if data.pf?
      [player_name, f] = data.pf
      for object in @engine.objects when object.renderer?.mesh_name is player_name
        object.facing = f
    else if data.pl?
      [player_name, l] = data.pl
      for object in @engine.objects when object.renderer?.mesh_name is player_name
        object.flashlightLit = l
    else if data.pv?
      [player_name, v] = data.pv
      for object in @engine.objects when object.renderer?.mesh_name is player_name
        object.visible = v
    else if data.pw? # player win
      [player_name, who] = data.pw
      for object in @engine.objects when object.renderer?.mesh_name is player_name
        @engine.TriggerSync 'OnEndRound', @engine.GetObject(who), true
