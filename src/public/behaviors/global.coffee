Math.rand = (m,x) -> Math.round(Math.random() * (x-m)) + m
delay = (s, f) -> setTimeout f, s
mapRoot = 'models/map1'
map = 'map1.gltf'
objects = {}
whoami = null
MULTIPLAYER = false

class VideoSettings
  @fps: 1 # TODO: find out why mathematically using 60 here lowers it to 10 actual fps

class Time
  @now: -> (new Date()).getTime()

class Video
  @canvas: document.getElementById 'mainCanvas'
  @ctx: @canvas.getContext '2d'
  @pixelBuf: undefined
  @drawPixel: (x, y, r, g, b, a) ->
    index = (x + y * @canvas.width) * 4
    @pixelBuf.data[index + 0] = r
    @pixelBuf.data[index + 1] = g
    @pixelBuf.data[index + 2] = b
    @pixelBuf.data[index + 3] = a
  @updateCanvas: ->
    @ctx.putImageData @pixelBuf, 0, 0

class Engine
  @running: true
  @run: ->
    console.log 'Starting at '+(new Date())
    @startup =>
      updateInterval = 1000/VideoSettings.fps
      maxUpdateLatency = updateInterval * 1
      drawInterval   = 1000/VideoSettings.fps # should be >= update interval
      skippedFrames  = 1
      maxSkipFrames  = 5
      nextUpdate     = Time.now()
      framesRendered = 0
      setInterval (-> console.log "#{framesRendered}fps"; framesRendered = 0), 1000

      #ticks = 0
      tick = =>
        #return if ticks++ > 7
        next = => requestAnimationFrame tick if @running # loop no more than 60fps
        now = Time.now()

        # if the time to update + draw has left the nextUpdate scheduled
        # ridiculously far behind in the past, then resync the period for
        # the nextUpdate to happen immediately, and then resume at intervals from there
        # otherwise a string of potentially long updates would get called in rapid succession
        nextUpdate = now if nextUpdate - maxUpdateLatency > now # resync
        # TODO: this can be expanded to signal unacceptable timing
        #   and to provide an opportunity to skip some non-essential updates
        #   in order to catch up faster

        if now >= nextUpdate # past-due for an update
          nextUpdate += updateInterval # schedule next update an interval apart
          @update()

          # notice that without an update, we won't have anything new to draw.

          # notice some upates can take too long;
          # here we're allowed to skip drawing a few frames per second,
          # in order to catch-up.
          if now > nextUpdate and # if past time for the next scheduled update, and
            skippedFrames < maxSkipFrames # we can still afford to skip a few frames
               skippedFrames++ # skip one more frame
          else # we have time, or we can't afford to skip any more frames
            @draw() # take time to draw
            framesRendered++ # for measuring actual fps
            skippedFrames = 0 # frames may be skipped from here, if needed
        else
          sleepTime = nextUpdate - now
          if sleepTime > 0
            return delay sleepTime, next

        next()
      tick()

  @stop: ->
  @startup: (cb) ->
    focused = false
    step = 10
    document.addEventListener 'mousedown', ((e) ->
      focused = e.target is Video.canvas
      return unless focused
      #console.log 'buttons: ', e.buttons
      e.preventDefault()
    ), true
    document.addEventListener 'keydown', ((e) ->
      return unless focused
      #console.log 'keyCode: ', e.keyCode
      switch e.keyCode
        when 87 # w
          # TODO: use MonoBehavior style Transform with Vector here
          objects[whoami]?.yT -= step
        when 65 # a
          objects[whoami]?.xT -= step
        when 83 # s
          objects[whoami]?.yT += step
        when 68 # d
          objects[whoami]?.xT += step
      e.preventDefault()
    ), true

 
    # Touch events
    startX = startY = 0
    Video.canvas.addEventListener 'touchstart', (e) ->
      startX = e.touches[0].pageX
      startY = e.touches[0].pageY
      e.preventDefault()

    Video.canvas.addEventListener 'touchend', (e) ->
      endX = e.changedTouches[0].pageX
      endY = e.changedTouches[0].pageY
      distance = Math.sqrt(Math.pow(startX - endX, 2) + Math.pow(startY - endY, 2))
      if endX < startX
        objects[whoami]?.xT -= step
      else
        objects[whoami]?.xT += step
      if endY < startY
        objects[whoami]?.yT -= step
      else
        objects[whoami]?.yT += step
      e.preventDefault()


    # mouse capture
    prefix = if Video.canvas.requestPointerLock then '' else if Video.canvas.mozRequestPointerLock then 'moz' else 'webkit'
    Video.canvas.onclick = ->
      Video.canvas[(if prefix then prefix+'R' else 'r')+'equestPointerLock']()

    capturedMouseMove = (e) ->
      # store the min/max so we can draw a rect
      # and calculate angles and vector between
      # calls to update()
      movX = e[(if prefix then prefix+'M' else 'm') + 'ovementX']
      movY = e[(if prefix then prefix+'M' else 'm') + 'ovementY']
      x = e.clientX + movX
      y = e.clientY + movY
      objects[whoami]?.lastX ||= x
      objects[whoami]?.targetX = x
      objects[whoami]?.lastY ||= y
      objects[whoami]?.targetY = y
      #console.log movX: movX, movY: movY, x: x, y: y
      e.preventDefault()

    document.addEventListener prefix+'pointerlockchange', (->
      if document[(if prefix then prefix+'P' else 'p') + 'ointerLockElement'] is Video.canvas
        console.log 'The pointer lock status is now locked'
        document.addEventListener 'mousemove', capturedMouseMove, false
      else
        console.log 'The pointer lock status is now unlocked'
        document.removeEventListener 'mousemove', capturedMouseMove, false
    ), false


    initMap map, cb
  @shutdown: ->


  @update: ->
    # check player collision
    for name in ['player1', 'player2']
      obj = objects[name]
      if obj.lastX and obj.targetX and obj.lastY and obj.targetY
        rad = getAngle obj.lastX, obj.lastY, obj.targetX, obj.targetY
        deg = rad2deg rad
        console.log name: name, deg: deg

        # rotate player
        rot = [
          1, 0, 0, 0,
          0, Math.cos(deg), -1 * Math.sin(deg), 0,
          0, Math.sin(deg), Math.cos(deg), 0,
          0, 0, 0, 1
        ]
        for nil, i in obj.vertices
          obj.vertices[i] = transform rot, obj.vertices[i]

      obj.lastX = obj.targetX = obj.lastY = obj.targetY = null

      if obj.xT or obj.yT
        if collidesWith obj, objects['wall']
          console.log 'collide'
        else if collidesWith obj, objects[if whoami is 'player1' then 'player2' else 'player1']
          console.log 'collide'
          #alert 'game over!'
          #location.reload()
        else
          obj.x += obj.xT
          obj.y += obj.yT
          if MULTIPLAYER
            socket.send JSON.stringify pm: [myid, obj.x, obj.y]
        obj.xT = obj.yT = obj.zT = 0

  @draw: ->
    #Video.pixelBuf = Video.ctx.createImageData Video.canvas.width, Video.canvas.height
    #for i in [0...10]
    #  Video.drawPixel Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255
    #Video.updateCanvas()
    Video.ctx.clearRect 0 , 0 , Video.canvas.width, Video.canvas.height
    drawMap()

collidesWith = (a, b) ->
  for nil, i in a.vertices by 3
    aT = [{
      x: a.vertices[i].x + a.x + a.xT
      y: a.vertices[i].y + a.y + a.yT
    },{
      x: a.vertices[i+1].x + a.x + a.xT
      y: a.vertices[i+1].y + a.y + a.yT
    },{
      x: a.vertices[i+2].x + a.x + a.xT
      y: a.vertices[i+2].y + a.y + a.yT
    }]
    for nil, ii in b.vertices by 3
      bT = [{
        x: b.vertices[ii].x + b.y
        y: b.vertices[ii].y + b.y
      },{
        x: b.vertices[ii+1].x + b.x
        y: b.vertices[ii+1].y + b.y
      },{
        x: b.vertices[ii+2].x + b.x
        y: b.vertices[ii+2].y + b.y
      }]
      if trianglesIntersect aT, bT
        return true
  return false

trianglesIntersect = (a, b) ->
  # cheating by converting them to rectangles
  # because they're always at 90 degree angles right now
  l1x = Math.min a[0].x, a[1].x, a[2].x
  r1x = Math.max a[0].x, a[1].x, a[2].x
  l1y = Math.max a[0].y, a[1].y, a[2].y
  r1y = Math.min a[0].y, a[1].y, a[2].y
  l2x = Math.min b[0].x, b[1].x, b[2].x
  r2x = Math.max b[0].x, b[1].x, b[2].x
  l2y = Math.max b[0].y, b[1].y, b[2].y
  r2y = Math.min b[0].y, b[1].y, b[2].y

  return false if l1x > r2x || l2x > r1x # aside
  return false if l1y < r2y || l2y < r1y # above or below
  return true


# 3D Space

#class Vector3
#  constructor: (@x, @y, @z) ->
# minimal vector lib
Vector =
  UP: x: 0, y: 1, z: 0
  ZERO: x: 0, y: 0, z: 0
  dotProduct: (a, b) ->
    (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
  crossProduct: (a, b) ->
    x: (a.y * b.z) - (a.z * b.y)
    y: (a.z * b.x) - (a.x * b.z)
    z: (a.x & b.y) - (a.y * b.x)
  scale: (a, t) ->
    x: a.x * t
    y: a.y * t
    z: a.z * t
  unitVector: (a) ->
    Vector.scale a, 1 / Vector.length a
  add: (a, b) ->
    x: a.x + b.x
    y: a.y + b.y
    z: a.z + b.z
  add3: (a, b, c) ->
    x: a.x + b.x + c.x
    y: a.y + b.y + c.y
    z: a.z + b.z + c.z
  subtract: (a, b) ->
    x: a.x - b.x
    y: a.y - b.y
    z: a.z - b.z
  length: (a) -> # measured by Euclidean norm
    Math.sqrt Vector.dotProduct a, a



dotProductVec4 = (a, b) ->
  #[ # column-major
  #  (a[0]*b[0])  + (a[1]*b[1])  + (a[2]*b[2])  + (a[3]*b[3]),
  #  (a[0]*b[4])  + (a[1]*b[5])  + (a[2]*b[6])  + (a[3]*b[7]),
  #  (a[0]*b[8])  + (a[1]*b[9])  + (a[2]*b[10]) + (a[3]*b[11]),
  #  (a[0]*b[12]) + (a[1]*b[13]) + (a[2]*b[14]) + (a[3]*b[15])
  #]
  [ # row-major
    (a[0]*b[0]) + (a[1]*b[4]) + (a[2]*b[8])  + (a[3]*b[12]),
    (a[0]*b[1]) + (a[1]*b[5]) + (a[2]*b[9])  + (a[3]*b[13]),
    (a[0]*b[2]) + (a[1]*b[6]) + (a[2]*b[10]) + (a[3]*b[14]),
    (a[0]*b[3]) + (a[1]*b[7]) + (a[2]*b[11]) + (a[3]*b[15])
  ]



class Transform
  #position: new Vector3 0, 0, 0
  #rotation
  #localPosition
  #localRotation
  translate: (translation) ->



# Objects

class Behavior
  transform: new Transform()

# Game

class Box extends Behavior

  update: ->
    transform.translate
  draw: ->
    Video.drawPixel Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255





















getAngle = (x1, y1, x2, y2) ->
  distY = Math.abs(y2-y1) # opposite
  distX = Math.abs(x2-x1) # adjacent
  dist  = Math.sqrt((distY*distY)+(distX*distX)) # hypotenuse
  asin  = Math.asin(distY/dist) # return angle in radians
  #console.log x1: x1, y1: y1, x2: x2, y2: y2, distX: distX, distY: distY, dist: dist, asin: asin
  return asin or 0

rad2deg = (radians) ->
  return radians*(180/Math.PI)










getFile = (type, url, cb) ->
  xhr = new XMLHttpRequest()
  xhr.onreadystatechange = ->
    if @readyState is 4 and @status is 200
      cb @response
  xhr.open 'GET', url
  xhr.responseType = type
  xhr.send()

getAttrVal = (data, accessor_id, cb) ->
  accessor = data.accessors[accessor_id]
  bufferView = data.bufferViews[accessor.bufferView]
  buffer = data.buffers[bufferView.buffer]

  a = (next) ->
    return next() if buffer.data
    getFile 'blob', "#{mapRoot}/#{buffer.uri}", (bin) ->
      if buffer.type is 'arraybuffer'
        reader = new FileReader
        reader.addEventListener 'loadend', ->
          buffer.data = reader.result
          next()
        reader.readAsArrayBuffer bin

  b = ->
    viewSlice = buffer.data.slice bufferView.byteOffset, bufferView.byteOffset + bufferView.byteLength
    attrSlice = viewSlice.slice accessor.byteOffset, accessor.byteOffset + (accessor.byteStride * accessor.count)
    switch accessor.type
      when 'VEC3'
        cb new Float32Array attrSlice

  a b

recursivelyFindSceneMeshesWithTransforms = (data) ->


loadMap = (map, done_cb, cb) ->
  getFile 'application/json', map, (response) ->
    data = JSON.parse response
    flow = new async
    matrixHierarchy = []
    for node in data.scenes[data.scene].nodes
      matrixHierarchy.push data.nodes[node].matrix
      for child in data.nodes[node].children
        matrixHierarchy.push data.nodes[child].matrix
        for id in data.nodes[child].meshes
          color = ''
          rgba = data.materials[data.meshes[id].primitives[0].material].instanceTechnique.values?.diffuse
          color = "rgba(#{Math.ceil 60+(255*rgba[0])}, #{Math.ceil 30+(255*rgba[1])}, #{Math.ceil 0+(255*rgba[2])}, #{Math.round rgba[3], 1})"
          ((id, h, color) ->
            flow.serial (next) ->
              getAttrVal data, data.meshes[id].primitives[0].attributes.POSITION, (vertices) ->
                cb data.meshes[id].name, h, color, vertices
                next()
          )(id, matrixHierarchy.slice(0), color)
        matrixHierarchy.pop()
    flow.go (err) ->
      done_cb()


initMap = (map, cb) ->
  loadMap "#{mapRoot}/#{map}", cb, (name, h, fill_color, vertices) ->
    # push all vertices into a new game object
    object =
      name: name
      vertices: []
      fill: fill_color
      x: null
      y: null
      z: null
      xT: 0
      yT: 0
      zT: 0
      width: null
      height: null
      depth: null
      min: [null,null,null]
      max: [null,null,null]

    [world, local] = h
    h = [
      local

      world

      ## rotate to top orthogonal perspective
      # this doesn't work perfectly because its rotating around an arbitrary origin
      # so for now i rotate everything in blender first, instead
      #[
      #  1, 0, 0, 0,
      #  0, Math.cos(90), -1 * Math.sin(90), 0,
      #  0, Math.sin(90), Math.cos(90), 0,
      #  0, 0, 0, 1
      #]

      # flip along x-axis
      [
        1, 0, 0, 0
        0, -1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
      ]

      # and zoom to fit canvas
      [
        35, 0, 0, 0
        0, 35, 0, 0,
        0, 0, 35, 0,
        0, 0, 0, 1
      ]

      # center
      [
        1, 0, 0, 0
        0, 1, 0, 0,
        0, 0, 1, 0,
        180, 320, 0, 1
      ]

    ]

    xmin = ymin = zmin = xmax = ymax = zmax = null
    for nil, i in vertices by 3
      p = transform h, {
        x: vertices[i]
        y: vertices[i+1]
        z: vertices[i+2]
      }
      xmin = Math.min p.x, if null is xmin then p.x else xmin
      ymin = Math.min p.y, if null is ymin then p.y else ymin
      zmin = Math.min p.z, if null is zmin then p.z else zmin
      xmax = Math.max p.x, if null is xmax then p.x else xmax
      ymax = Math.max p.y, if null is ymax then p.y else ymax
      zmax = Math.max p.z, if null is zmax then p.z else zmax
      object.vertices.push p

    object.min = [xmin, ymin, zmin]
    object.max = [xmax, ymax, zmax]
    object.width = xmax - xmin
    object.height = ymax - ymin
    object.depth = zmax - zmin
    object.x = 0
    object.y = 0
    object.z = 0

    objects[name] = object
    console.log object


transform = (h, p) ->
  for matrix in h
    [p.x, p.y, p.z] = dotProductVec4 [p.x, p.y, p.z, 1], matrix
  return p

drawMap = ->
  for name, object of objects
    Video.ctx.lineWidth = 1
    Video.ctx.strokeStyle = 'rgba(255, 255, 255, .15)'

    # draw triangles
    p = object.vertices
    for nil, i in p by 3
      Video.ctx.fillStyle = object.fill
      Video.ctx.beginPath()
      Video.ctx.moveTo p[i].x+object.x, p[i].y+object.y
      Video.ctx.lineTo p[i+1].x+object.x, p[i+1].y+object.y
      Video.ctx.lineTo p[i+2].x+object.x, p[i+2].y+object.y
      Video.ctx.closePath()
      Video.ctx.fill()
      Video.ctx.stroke()












Engine.run()







unless MULTIPLAYER
  myid = 1
  whoami = 'player1'
else
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

