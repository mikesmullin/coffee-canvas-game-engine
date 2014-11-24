Math.rand = (m,x) -> Math.round(Math.random() * (x-m)) + m
delay = (s, f) -> setTimeout f, s
mapRoot = '/models/map1'
map = 'map1.gltf'
objects = {}

class VideoSettings
  @fps: 24 # TODO: find out why mathematically using 60 here lowers it to 10 actual fps

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
      #setInterval (-> console.log "#{framesRendered}fps"; framesRendered = 0), 1000

      tick = =>
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
      #tick()
      @draw()

  @stop: ->
  @startup: (cb) ->
    focused = false
    document.addEventListener 'mousedown', ((e) ->
      focused = e.target is Video.canvas
      return unless focused
      #console.log 'buttons: ', e.buttons
    ), true
    document.addEventListener 'keydown', ((e) ->
      return unless focused
      #console.log 'keyCode: ', e.keyCode
      switch e.keyCode
        when 87 # w
          # TODO: use MonoBehavior style Transform with Vector here
          1 #objects['player1'].x
        when 65 # a
          1
        when 83 # s
          1
        when 68 # d
          1
    ), true
    initMap map, cb
  @shutdown: ->


  @update: ->


  @draw: ->
    #Video.pixelBuf = Video.ctx.createImageData Video.canvas.width, Video.canvas.height
    #for i in [0...10]
    #  Video.drawPixel Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255
    #Video.updateCanvas()
    Video.ctx.clearRect 0 , 0 , Video.canvas.width, Video.canvas.height
    drawMap()


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
        40, 0, 0, 0
        0, 40, 0, 0,
        0, 0, 40, 0,
        0, 0, 0, 1
      ]

      # center
      [
        1, 0, 0, 0
        0, 1, 0, 0,
        0, 0, 1, 0,
        170, 270, 0, 1
      ]

    ]

    #xmin = ymin = zmin = xmax = ymax = zmax = null
    for nil, i in vertices by 3
      p = transform h, {
        x: vertices[i]
        y: vertices[i+1]
        z: vertices[i+2]
      }
      #xmin = Math.min p.x, if null is xmin then p.x else xmin
      #ymin = Math.min p.y, if null is ymin then p.y else ymin
      #zmin = Math.min p.z, if null is zmin then p.z else zmin
      #xmax = Math.max p.x, if null is xmax then p.x else xmax
      #ymax = Math.max p.y, if null is ymax then p.y else ymax
      #zmax = Math.max p.z, if null is zmax then p.z else zmax
      object.vertices.push p

    #object.width = object.bounding_box.max[0] - object.bounding_box.min[0]
    #object.height = object.bounding_box.max[1] - object.bounding_box.min[1]
    #object.depth = object.bounding_box.max[2] - object.bounding_box.min[2]
    #object.x = object.bounding_box.min[0]
    #object.y = object.bounding_box.min[1]
    #object.z = object.bounding_box.min[2]

    objects[name] = object
    _v = ''
    for v in object.vertices
      _v += "[#{v.x},#{v.y},#{v.z}],"
    console.log "#{object.name}: #{_v}"


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
      Video.ctx.moveTo p[i].x, p[i].y
      Video.ctx.lineTo p[i+1].x, p[i+1].y
      Video.ctx.lineTo p[i+2].x, p[i+2].y
      Video.ctx.closePath()
      Video.ctx.fill()
      Video.ctx.stroke()












Engine.run()

