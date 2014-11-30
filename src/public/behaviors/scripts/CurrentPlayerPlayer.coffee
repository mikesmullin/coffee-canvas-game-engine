define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentPlayerPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"
      if @object.constructor.name is 'Player' and collidingObject.constructor.name is 'Monster'
        alert 'You were caught by the seeker! You LOOSE!'
        location.reload()

    Update: (engine) ->
      if Input.GetButtonDown 'Use'
        console.log 'using'

      if Input.GetButtonDown 'Fire'
        # TODO: interact with doors/drawers
        console.log 'interact'

      if Input.GetButtonDown 'Alt Fire'
        console.log 'toggle flashlight'
        @object.flashlightLit = not @object.flashlightLit
