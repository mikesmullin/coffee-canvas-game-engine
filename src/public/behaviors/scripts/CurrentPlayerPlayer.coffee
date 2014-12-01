define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentPlayerPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Player'
        switch collidingObject.constructor.name
          when 'Monster'
            if collidingObject.visible
              unless @object.engine.network.connected # only used for single-player
                @object.engine.TriggerObjectSync 'OnEndRound', @object, collidingObject
            else
              console.log 'eerie breathing is heard'

          when 'Exit'
            if @object.constructor.name is 'Player'
              console.log 'player escaped'
              @object.engine.TriggerObjectSync 'OnEndRound', @object, @object


    Update: (engine) ->
      # set facing direction based on mouse input; mimic 3D mouse look
      SENSITIVITY = 0.2
      @object.SetFacing @object.facing - (SENSITIVITY * Input.GetAxisRaw('Mouse X'))

      #if Input.GetButtonDown 'Use'
      #  console.log 'using'

      if Input.GetButtonDown 'Fire'
        # TODO: interact with doors/drawers
        console.log 'interact'

      if Input.GetButtonDown 'Alt Fire'
        console.log 'toggle flashlight'
        @object.ToggleFlashlight()

    DrawGUI: (engine) ->
      engine.Info 'Controls: LClick - Interact, RClick - toggle light', line: 50, color: 'red', size: 12
      engine.Info 'Objective: Sneak and hide from the seeker', line: 51, color: 'gray', size: 12
