define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentPlayerPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Player' and collidingObject.constructor.name is 'Monster'
        if collidingObject.visible
          # TODO: in multiplayer, wait for network server to tell player
          #  that they were attacked during collision and lost
          alert 'You were caught by the seeker! You LOOSE!'
          location.reload()
        else
          console.log 'eerie breathing is heard'

    Update: (engine) ->
      #if Input.GetButtonDown 'Use'
      #  console.log 'using'

      if Input.GetButtonDown 'Fire'
        # TODO: interact with doors/drawers
        console.log 'interact'

      if Input.GetButtonDown 'Alt Fire'
        console.log 'toggle flashlight'
        @object.ToggleFlashlight()

    DrawGUI: (engine) ->
      engine.Info 'Controls: LClick - Interact, RClick - toggle light', 50, 'red', 12
      engine.Info 'Objective: Sneak and hide from the seeker', 51, 'gray', 12
