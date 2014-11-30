define [
  'components/Script'
  'lib/Vector3'
  'lib/GMath'
  'lib/Time'
], (Script, Vector3, GMath, Time) ->
  class AutoPilot extends Script
    constructor: ->
      super
      @Reseed()
      @Periodic()

    Periodic: ->
      Time.Delay @seed.i3, =>
        @Reseed()
        @Periodic()

    Reseed: ->
      @seed =
        x: GMath.rand 300, 400
        y: GMath.rand 300, 400
        i1: GMath.rand 2, 15
        i2: @seed?.i2 or GMath.rand 5, 9
        i3: GMath.rand 2000, 6000
        r: GMath.rand 1, 10

    OnControllerColliderHit: (engine, collidingObject) ->
      @Reseed() if 3 is GMath.rand 1, 3

    Update: (engine) ->
      # oscillating player movement
      x = 0; y = 0
      if @seed.r >= 4
        x = engine.deltaTime * GMath.oscillate @seed.x, @seed.i1, 0, engine.time
        y = engine.deltaTime * GMath.oscillate @seed.y, @seed.i1/2, 0, engine.time
      else
        if @seed.r is 1 or @seed.r is 2
          x = engine.deltaTime * ((@seed.x - 350) * 10)
        else # if @seed.r is 2 or @seed.r is 3
          y = engine.deltaTime * ((@seed.y - 350) * 10)
      @object.collider.Move engine, new Vector3 x, y, 0

      # interactions
      switch @object.constructor.name
        when 'Monster'
          @object.ToggleVisibility GMath.oscillate(1, @seed.i2, 1, engine.time) > 1
        when 'Player'
          @object.ToggleFlashlight GMath.oscillate(1, @seed.i2, 1, engine.time) > 1
