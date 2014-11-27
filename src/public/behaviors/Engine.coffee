define -> class Engine
  constructor: ->
    # TODO: use my custom @extends for enhanced modularity? e.g., no for loops and class registries?
    # TODO: require all behaviors
      # TODO: they should require all their dependencies incl. libs and components




  VideoSettings: class
    @fps: 1 # TODO: find out why mathematically using 60 here lowers it to 10 actual fps

  Video: class
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
