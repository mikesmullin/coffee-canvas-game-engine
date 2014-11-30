define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentMonsterPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Monster' and collidingObject.constructor.name is 'Player'
        if @object.visible and Input.GetButtonDown 'Fire'
          console.log 'hit'
          alert 'You grabbed the hider! You WIN!'
          location.reload()

    Update: (engine) ->
      if Input.GetButtonDown 'Use'
        console.log 'toggle visibility'
        @object.ToggleVisibility()

      if Input.GetButtonDown 'Fire'
        console.log 'attack. miss?'
        # TODO: can also interact with doors/drawers

      if Input.GetButtonDown 'Alt Fire'
        console.log 'alt attack'
