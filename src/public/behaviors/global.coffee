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

    updateInterval = 1000/VideoSettings.fps
    maxUpdateLatency = updateInterval * 1
    drawInterval   = 1000/VideoSettings.fps # should be >= update interval
    skippedFrames  = 1
    maxSkipFrames  = 5
    nextUpdate     = Time.now()
    framesRendered = 0
    setInterval (-> console.log "#{framesRendered}fps"; framesRendered = 0), 1000

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
    tick()

  @stop: ->
  @startup: ->
  @shutdown: ->
  @update: ->

  @draw: ->
    Video.pixelBuf = Video.ctx.createImageData Video.canvas.width, Video.canvas.height
    for i in [0...10]
      Video.drawPixel Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255
    Video.updateCanvas()


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















Engine.run()
