define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentMonsterPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Monster'
        switch collidingObject.constructor.name
          when 'Player'
            if @object.visible and Input.GetButtonDown 'Fire'
              console.log 'monster hit player'
              @object.engine.TriggerObjectSync 'OnEndRound', @object, @object
          when 'Exit'
            console.log 'monster gave up'
            @object.engine.TriggerObjectSync 'OnEndRound', @object, engine.GetObject 'Player'

    Update: (engine) ->
      if Input.GetButtonDown 'Use'
        console.log 'toggle visibility'
        @object.ToggleVisibility()

      if Input.GetButtonDown 'Fire'
        console.log 'attack. miss?'
        # TODO: can also interact with doors/drawers

      if Input.GetButtonDown 'Alt Fire'
        console.log 'alt attack'

    DrawGUI: (engine) ->
      engine.Info 'Controls: E - toggle visibility, LClick - capture', line: 50, color: 'red', size: 12
      engine.Info 'Objective: Scare or capture the hider', line: 51, color: 'gray', size: 12
