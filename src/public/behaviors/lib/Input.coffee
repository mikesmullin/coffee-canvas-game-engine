define -> class Input
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

    cb()
