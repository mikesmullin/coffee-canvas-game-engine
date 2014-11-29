define [
  'components/Script'
  'lib/Input'
  'lib/Vector3'
], (Script, Input, Vector3) ->
  class TopDownController2D extends Script
    constructor: ->
      super

      # TODO: rename these states everywhere they are used
      @CharacterState =
        Idle: 0
        Walking: 1 # Crouching/Sneaking
        Trotting: 2 # Walking
        Running: 3 # Running

      @_characterState = null

      # The speed when walking
      @walkSpeed = 2.0

      # after trotAfterSeconds of walking we trot with trotSpeed
      @trotSpeed = 4.0
      # when pressing "Fire3" button (cmd) we start running
      @runSpeed = 6.0

      @speedSmoothing = 10.0
      @rotateSpeed = 500.0
      @trotAfterSeconds = 3.0

      # The current move direction in x-z
      @moveDirection = Vector3.zero
      # The current vertical speed
      @verticalSpeed = 0.0
      # The current x-z move speed
      @moveSpeed = 0.0

      # The last collision flags returned from controller.Move
      @collisionFlags = null

      # Is the user pressing any keys?
      @isMoving = false
      # When did the user start walking (Used for going into trot after a while)
      @walkTimeStart = 0.0

    Awake: (engine) ->
      # TODO: make this work, if needed (e.g., waking from pause or hibernate)

    Update: (engine) ->
      #console.log 'update ', Input.axis
      speed = 420.0 # pixels per second
      @object.transform.position.x += (speed * engine.deltaTime * Input.GetAxisRaw 'Horizontal')
      @object.transform.position.y += (speed * engine.deltaTime * Input.GetAxisRaw 'Vertical')
      return

      #@UpdateSmoothedMovementDirection()

      ## Calculate actual motion
      #movement = moveDirection * moveSpeed + Vector3 (0, verticalSpeed, 0) + inAirVelocity
      #movement *= Time.deltaTime

      ## Move the controller
      #controller = GetComponent(CharacterController)
      #collisionFlags = controller.Move(movement)

    UpdateSmoothedMovementDirection: ->
      cameraTransform = Camera.main.transform # TODO: need Camera object?

      # Forward vector relative to the camera along the x-z plane
      forward = cameraTransform.TransformDirection(Vector3.forward) # TODO: need TransformDirection method?
      forward.y = 0
      forward = forward.normalized

      # Right vector relative to the camera
      # Always orthogonal to the forward vector
      right = new Vector3(forward.z, 0, -forward.x)

      v = Input.GetAxisRaw("Vertical")
      h = Input.GetAxisRaw("Horizontal")

      # Are we moving backwards or looking backwards
      if (v < -0.2)
        movingBack = true
      else
        movingBack = false

      wasMoving = isMoving
      isMoving = Mathf.Abs (h) > 0.1 || Mathf.Abs (v) > 0.1

      # Target direction relative to the camera
      targetDirection = h * right + v * forward

      # We store speed and direction separately,
      # so that when the character stands still we still have a valid forward direction
      # moveDirection is always normalized, and we only update it if there is user input.
      if targetDirection != Vector3.zero # TODO: ensure this type of equality is checking x, y, z values and not object instance
        # If we are really slow, just snap to the target direction
        if moveSpeed < walkSpeed * 0.9 && grounded
          moveDirection = targetDirection.normalized
        # Otherwise smoothly turn towards it
        else
          moveDirection = Vector3.RotateTowards(moveDirection, targetDirection, rotateSpeed * Mathf.Deg2Rad * Time.deltaTime, 1000)
          moveDirection = moveDirection.normalized

      # Smooth the speed based on the current target direction
      curSmooth = speedSmoothing * Time.deltaTime

      # Choose target speed
      #* We want to support analog input but make sure you cant walk faster diagonally than just forward or sideways
      targetSpeed = Mathf.Min(targetDirection.magnitude, 1.0)

      _characterState = CharacterState.Idle

      # Pick speed modifier
      if Input.GetKey (KeyCode.LeftShift) || Input.GetKey (KeyCode.RightShift)
        targetSpeed *= runSpeed
        _characterState = CharacterState.Running
      else if Time.time - trotAfterSeconds > walkTimeStart
        targetSpeed *= trotSpeed
        _characterState = CharacterState.Trotting
      else
        targetSpeed *= walkSpeed
        _characterState = CharacterState.Walking

      moveSpeed = Mathf.Lerp(moveSpeed, targetSpeed, curSmooth)

      # Reset walk time start when we slow down
      if moveSpeed < walkSpeed * 0.3
        walkTimeStart = Time.time
