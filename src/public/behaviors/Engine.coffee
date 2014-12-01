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

  Info: (msg, {line, color, size }) ->
    msg = ''+msg
    line ||= 1
    color ||= 'white'
    size ||= 9
    @canvas.ctx.font = "normal #{size}px silkscreennormal"
    @canvas.ctx.fillStyle = color
    @canvas.ctx.fillText msg, @canvas.canvas.width - (size*msg.length) - 10, 10+(line*size)

  GetObject: (name) ->
    for object in @objects when object.constructor.name is name
      return object

  Start: (engine, cb) ->
    @started = Time.Now()
    @time = 0
    Input.Start engine, cb

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
      @fps             = 0
      Time.Interval    1000, => @fps = framesRendered; framesRendered = 0
      @deltaTime       = 0 # time to complete last frame; makes interpolation frame-rate independent
      lastFrameStarted = 0

      #ticks = 0
      tick = =>
        #return if ticks++ > 7
        next = => requestAnimationFrame tick if @running # loop no more than 60fps
        now = Time.Now()
        @deltaTime = (now - lastFrameStarted) / 1000 if lastFrameStarted
        lastFrameStarted = now

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
          @TriggerSync 'Update'; @TriggerSync 'FinalUpdate'

          # notice that without an update, we won't have anything new to draw.

          # notice some updates can take too long;
          # here we're allowed to skip drawing a few frames per second,
          # in order to catch-up.
          if Time.Now() > nextUpdate and # if past time for the next scheduled update, and
            skippedFrames < maxSkipFrames # we can still afford to skip a few frames
               skippedFrames++ # skip one more frame
          else # we have time, or we can't afford to skip any more frames
            @TriggerSync 'Draw'; @TriggerSync 'DrawGUI' # take time to draw
            framesRendered++ # for measuring actual fps
            skippedFrames = 0 # frames may be skipped from here, if needed
        else
          sleepTime = nextUpdate - now
          if sleepTime > 0
            return Time.Delay sleepTime, next

        next()
      tick()

  Update: (engine) ->

  FinalUpdate: (engine) ->
    Input.FinalUpdate engine

  Draw: (engine) ->
    # engine.time is seconds since start of game; used for interpolation
    # only updated once per frame
    @time = (Time.Now() - @started) / 1000
    @canvas.Clear()

  DrawGUI: (engine) ->
    @Info @fps, line: 1, color: 'lime', size: 45

  Stop: (engine) ->
    @running = false
    @TriggerSync 'Shutdown'

  Shutdown: (engine) ->
    #TODO: we may want to make this async

  Bind: (obj) ->
    obj.engine = @
    @objects.push obj

  TriggerSync: (event, args...) ->
    args.unshift @
    @[event]?.apply @, args
    for obj in @objects when obj.enabled
      obj[event]?.apply obj, args
      for component in ['renderer', 'collider'] when obj[component]?.enabled
        obj[component][event]?.apply obj[component], args
      for cls, script of obj.scripts when script.enabled
        script[event]?.apply script, args
    return

  TriggerObjectSync: (event, obj, args...) ->
    args.unshift @
    obj[event]?.apply obj, args
    for component in ['renderer', 'collider'] when obj[component]?.enabled
      obj[component][event]?.apply obj[component], args
    for cls, script of obj.scripts when script.enabled
      script[event]?.apply script, args
    return

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
