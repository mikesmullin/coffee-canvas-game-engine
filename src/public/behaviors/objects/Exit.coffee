define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
], (Behavior, Transform, SegmentCollider) ->
  class Exit extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      #@collider = new SegmentCollider
      @renderer.enabled = false

    OnControllerColliderHit: (engine, collidingObject) ->
      if collidingObject.constructor.name is 'Exit'
        if @object.constructor.name is 'Player'
          console.log 'player escaped'
          @object.engine.TriggerObjectSync 'OnEndRound', @object, engine.GetObject 'Monster'
        else if @object.constructor.name is 'Monster'
          console.log 'monster wussed out.'
          @object.engine.TriggerObjectSync 'OnEndRound', @object, engine.GetObject 'Player'
