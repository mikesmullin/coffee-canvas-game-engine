Math.rand = (m,x) -> Math.round(Math.random() * (x-m)) + m
delay = (s, f) -> setTimeout f, s

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
    @startup()

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
  @startup: ->
  @shutdown: ->
  @update: ->

  @draw: ->
    Video.pixelBuf = Video.ctx.createImageData Video.canvas.width, Video.canvas.height


    #for i in [0...10]
    #  Video.drawPixel Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255

    Video.updateCanvas()
    drawMap map


# 3D Space

class Vector3
  constructor: (@x, @y, @z) ->

class Transform
  position: new Vector3 0, 0, 0
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






























mapRoot = '/models/map1'
map = 'map1.gltf'

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
    next() if buffer.data
    getFile 'blob', "#{mapRoot}/#{buffer.uri}", (bin) ->
      console.log bin, typeof bin
      console.log accessor: accessor, bufferView: bufferView, buffer: buffer
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

loadMap = (map, cb) ->
  getFile 'application/json', map, (response) ->
    data = JSON.parse response
    console.log data
    for name, mesh of data.meshes
      color = ''
      rgba = data.materials[mesh.primitives[0].material].instanceTechnique.values?.diffuse
      color = "rgba(#{Math.ceil 60+(255*rgba[0])}, #{Math.ceil 30+(255*rgba[1])}, #{Math.ceil 0+(255*rgba[2])}, #{Math.round rgba[3], 1})"
      ((color) ->
        getAttrVal data, mesh.primitives[0].attributes.POSITION, (vertices) ->
          cb name, color, vertices
      )(color)

drawMap = (map) ->
  loadMap "#{mapRoot}/#{map}", (name, fill_color, vertices) ->
    console.log "drawing #{name}..."

    Video.ctx.lineWidth = 1
    Video.ctx.strokeStyle = 'rgba(255, 255, 255, .15)'

    zoom = (p) ->
      #xs= 10* Video.ctx.canvas.width * p.x / map.width
      #y = 10* Video.ctx.canvas.height * (1 - p.y / map.height)
      x: 40 * (p.x+8), y: 40 * (p.y + 6), z: p.z

    for nil, i in vertices by 9
      # parse coordinates
      p = [zoom({
        x: vertices[i]
        y: vertices[i+1]
        z: vertices[i+2]
      }), zoom({
        x: vertices[i+3]
        y: vertices[i+4]
        z: vertices[i+5]
      }), zoom({
        x: vertices[i+6]
        y: vertices[i+7]
        z: vertices[i+8]
      })]
      console.log "##{(i)/9}: "+ JSON.stringify p

      Video.ctx.fillStyle = fill_color
      Video.ctx.beginPath()
      Video.ctx.moveTo p[0].x, p[0].y
      Video.ctx.lineTo p[1].x, p[1].y
      Video.ctx.lineTo p[2].x, p[2].y
      Video.ctx.closePath()
      Video.ctx.fill()
      Video.ctx.stroke()

      #debugger













Engine.run()

