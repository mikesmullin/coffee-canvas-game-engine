define [
  'components/Script'
  'lib/Input'
], (Script, Input) ->
  class CurrentMonsterPlayer extends Script
    OnControllerColliderHit: (engine, collidingObject) ->
      if @object.constructor.name is 'Monster' and collidingObject.constructor.name is 'Player'
        if @object.visible and Input.GetButtonDown 'Fire'
          console.log 'hit'
          @object.engine.TriggerObjectSync 'OnEndRound', @object, @object

    OnEndRound: (engine, winningObject) ->
      if @object is winningObject
        @object.engine.TriggerObjectSync 'OnWin', @object
      #else # player escaped exit?

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
