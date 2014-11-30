define [
  'components/Script'
  'lib/Vector3'
  'lib/GMath'
], (Script, Vector3, GMath) ->
  class AutoPilot extends Script
    Update: (engine) ->
      # oscillating player movement
      x = engine.deltaTime * GMath.oscillate 373, 5/2, 0, engine.time
      y = engine.deltaTime * GMath.oscillate 411, 5, 0, engine.time
      @object.collider.Move engine, new Vector3 x, y, 0

      # interactions
      switch @object.constructor.name
        when 'Monster'
          @object.ToggleVisibility GMath.oscillate(1, 5, 1, engine.time) > 1
        when 'Player'
          @object.ToggleFlashlight GMath.oscillate(1, 5, 1, engine.time) > 1
