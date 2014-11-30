define [
  'lib/GMath'
], (GMath) -> class Input
  @axis:
    Vertical:  0
    Horizontal: 0
    'Mouse X': 0
    'Mouse Y': 0
  @buttons:
    'Use': false

  @GetAxisRaw: (axis) -> @axis[axis]
  @GetButtonDown: (button) -> @buttons[button]

  @Start: (engine, cb) ->
    canvas = engine.canvas.canvas

    # mouse
    locked = false
    size = 640 # size of screen; assumes square ratio
    # for cross-browser compatibility
    pre = if canvas.requestPointerLock then '' else if canvas.mozRequestPointerLock then 'moz' else 'webkit'
    prefix = (s) -> return if pre is '' then s else pre + s[0].toUpperCase() + s.substr 1
    canvas.onclick = -> canvas[prefix 'requestPointerLock']()
    capturedMouseMove = (e) =>
      @axis['Mouse X'] = GMath.clamp e[prefix 'movementX'], - size/2, size/2
      @axis['Mouse Y'] = GMath.clamp e[prefix 'movementY'], - size/2, size/2
      e.preventDefault() # prevent browser fro reacting to event
    document.addEventListener pre + 'pointerlockchange', (->
      if locked = document[prefix 'pointerLockElement'] is canvas
        document.addEventListener 'mousemove', capturedMouseMove, false
      else
        document.removeEventListener 'mousemove', capturedMouseMove, false
    ), false

    # keyboard
    document.addEventListener 'keydown', ((e) =>
      return unless locked
      #engine.Log 'keyCode: '+ e.keyCode
      switch e.keyCode
        when 87 then @axis.Vertical = -1.0 # w
        when 65 then @axis.Horizontal = -1.0 # a
        when 83 then @axis.Vertical = 1.0 # s
        when 68 then @axis.Horizontal = 1.0 # d
        when 69 then @buttons.Use = true
      e.preventDefault() # prevent browser fro reacting to event
    ), true
    document.addEventListener 'keyup', ((e) =>
      return unless locked
      switch e.keyCode
        when 87, 83 then @axis.Vertical = 0 # w, s
        when 65, 68 then @axis.Horizontal = 0 # a, d
        when 69 then @buttons.Use = false
      e.preventDefault() # prevent browser fro reacting to event
    ), true

    # touch
    startX = startY = 0
    pixelUnit = 100 # max pretend-touch-joystick stretch area
    canvas.addEventListener 'touchstart', (e) =>
      startX = e.touches[0].clientX
      startY = e.touches[0].clientY
      e.preventDefault() # prevent browser fro reacting to event
    canvas.addEventListener 'touchmove', (e) =>
      endX = e.changedTouches[0].clientX
      endY = e.changedTouches[0].clientY
      @axis.Horizontal = GMath.clamp(endX - startX, - pixelUnit, pixelUnit) / pixelUnit
      @axis.Vertical = GMath.clamp(endY - startY, - pixelUnit, pixelUnit) / pixelUnit
      e.preventDefault() # prevent browser fro reacting to event
    canvas.addEventListener 'touchend', (e) =>
      @axis.Vertical = 0
      @axis.Horizontal = 0
      e.preventDefault() # prevent browser fro reacting to event

    #setInterval (=> console.log @axis), 500

    cb()
