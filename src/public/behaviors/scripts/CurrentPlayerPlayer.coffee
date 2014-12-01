define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentPlayerPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Player' and collidingObject.constructor.name is 'Monster'
        if collidingObject.visible
          unless @object.engine.network.connected # only used for single-player
            @object.engine.TriggerObjectSync 'OnEndRound', @object, collidingObject
        else
          console.log 'eerie breathing is heard'

    OnEndRound: (engine, winningObject) ->
      if @object isnt winningObject
        @object.engine.TriggerObjectSync 'OnLose', @object
      #else # player escaped exit?

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
