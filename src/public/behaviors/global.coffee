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




































drawMap = (map) ->
  #for name of map
  #  objs = map[name]
  #  if objs[0] and objs[0].faces
  #    ctx.fillStyle = 'red'
  #    i = 0

  #    while i < objs.length
  #      obj = objs[i]
  #      f = 0

  #      while f < obj.faces.length
  #        face = obj.faces[f]
  #        ctx.beginPath()
  #        v = 0

  #        while v < face.length
  #          vertice = obj.vertices[face[v]]
  #          x = ctx.canvas.width * vertice.x / map.width
  #          y = ctx.canvas.height * (1 - vertice.y / map.height)
  #          if v is 0
  #            ctx.moveTo x, y
  #          else
  #            ctx.lineTo x, y
  #          ++v
  #        ctx.fill()
  #        ++f
  #      ++i
  #    addLegend color, name, true

  console.log map

  for name, node of map.nodes
    continue if name is 'node_3' # not sure what to do with this yet
    # parse coordinates
    points = []
    for nil, i in node.matrix by 3
      points.push
        x: parseFloat node.matrix[i]
        y: parseFloat node.matrix[i+1]
        z: parseFloat node.matrix[i+2]

    console.log "drawing #{name}..."
    Video.ctx.strokeStyle = switch name
      when 'wall' then '#0000ff'
      when 'player1' then '#00ff00'
      when 'player2' then '#ff0000'
    Video.ctx.lineWidth = 1
    fp = null
    for p in points
      #x = 10* Video.ctx.canvas.width * p.x / map.width
      #y = 10* Video.ctx.canvas.height * (1 - p.y / map.height)
      x = (10 * p.x) + 100; y = (10 * p.y) + 100
      unless fp
        Video.ctx.beginPath()
        console.log "moveTo #{x}, #{y}"
        Video.ctx.moveTo x, y
        fp = p
      else
        console.log "lineTo #{x}, #{y}"
        Video.ctx.lineTo x, y
        Video.ctx.stroke()
        Video.ctx.beginPath()
        console.log "moveTo #{x}, #{y}"
        Video.ctx.moveTo x, y
      debugger
    fp.x = (10 * fp.x) + 100; fp.y = (10 * fp.y) + 100
    Video.ctx.lineTo fp.x, fp.y
    Video.ctx.stroke()















Engine.run()

