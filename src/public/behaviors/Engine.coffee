define [
  'lib/Time',
  'lib/Input',
  'lib/Canvas2D'
], (Time, Input, Canvas2D) -> class Engine
  @run: (obj) ->
    console.log 'Starting at '+(new Date())
    return

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
  @shutdown: ->
  @update: ->
  @draw: ->
  @draw: ->
    Video.ctx.clearRect 0 , 0 , Video.canvas.width, Video.canvas.height
