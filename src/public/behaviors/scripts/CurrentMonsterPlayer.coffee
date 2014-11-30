define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentMonsterPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"
      if @object.constructor.name is 'Monster' and collidingObject.constructor.name is 'Player'
        alert 'You caught the hider! You WIN!'
        location.reload()

    Update: (engine) ->
      if Input.GetButtonDown 'Use'
        console.log 'toggle visibility'

      if Input.GetButtonDown 'Fire'
        # TODO: can also interact with doors/drawers
        console.log 'attack'

      if Input.GetButtonDown 'Alt Fire'
        console.log 'alt attack'
