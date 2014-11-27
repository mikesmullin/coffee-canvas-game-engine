define [
  'async2'
  'lib/Time',
  'lib/Input',
  'lib/Canvas2D'
], (async, Time, Input, Canvas2D) -> class Engine
  constructor: ({ canvas_id }) ->
    @canvas = new Canvas2D id: canvas_id
    @objects = []
    @running = false

  Log: (msg) ->
    console.log msg

  Run: ->
    @running = true
    @Log 'Starting at '+(new Date())

    @Trigger 'Start', =>
      updateInterval   = 1000/@canvas.fps
      maxUpdateLatency = updateInterval * 1
      drawInterval     = 1000/@canvas.fps # should be >= update interval
      skippedFrames    = 1
      maxSkipFrames    = 5
      nextUpdate       = Time.Now()
      framesRendered   = 0
      Time.Interval 1000, => @Log "#{framesRendered}fps"; framesRendered = 0

      #ticks = 0
      tick = =>
        #return if ticks++ > 7
        next = => requestAnimationFrame tick if @running # loop no more than 60fps
        now = Time.Now()

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
          @TriggerSync 'Update'

          # notice that without an update, we won't have anything new to draw.

          # notice some upates can take too long;
          # here we're allowed to skip drawing a few frames per second,
          # in order to catch-up.
          if now > nextUpdate and # if past time for the next scheduled update, and
            skippedFrames < maxSkipFrames # we can still afford to skip a few frames
               skippedFrames++ # skip one more frame
          else # we have time, or we can't afford to skip any more frames
            @TriggerSync 'Draw' # take time to draw
            framesRendered++ # for measuring actual fps
            skippedFrames = 0 # frames may be skipped from here, if needed
        else
          sleepTime = nextUpdate - now
          if sleepTime > 0
            return Time.Delay sleepTime, next

        next()
      tick()

  Start: (engine, cb) ->
    @started = Time.Now()
    @time = 0
    cb()

  #Update: (engine) ->

  Draw: (engine) ->
    # engine.time is seconds since start of game; used for interpolation
    # only updated once per frame
    @time = Time.Now() - @started

    @canvas.Clear()

  #Stop: (engine, cb) -> cb()
  #Shutdown: (engine, cb) -> cb()

  Bind: (obj) ->
    @objects.push obj

  TriggerSync: (event) ->
    @[event]?()
    for obj in @objects when obj.enabled
      obj[event]?(@)
      for component in ['renderer'] when obj[component]?.enabled
        obj[component][event]?(@)

  Trigger: (event, cb) ->
    flow = new async
    o = [this].concat @objects
    for obj in o when obj[event]
      ((obj) =>
        flow.parallel (next) =>
          obj[event].call obj, @, next
      )(obj)
    flow.go (err) ->
      cb err
