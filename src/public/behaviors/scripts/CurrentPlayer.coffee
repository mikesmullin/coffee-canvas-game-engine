define [
  'components/Script'
  'scripts/TopDownController2D'
  'lib/Input'
  'lib/Visibility'
], (Script, TopDownController2D, Input, {Visibility}) ->
  class CurrentPlayer extends Script
    constructor: ->
      super
      @object.BindScript TopDownController2D
      @v = new Visibility
      @myVisibleArea = null
      @othersVisibleAreas = []

    OnControllerColliderHit: (collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"

      #if collidingObject.name is 'Monster'
        #alert 'game over!'
        #location.reload()

    Update: (engine) ->
      @v.ResetSegments()

      # calculate visibility for other players
      for object in engine.objects
        if ((object.constructor.name is 'Player' or
          object.constructor.name is 'Monster') and
          object.enabled and
          object isnt @object) # not me
            @v.AddSegments object.renderer.segments
            @v.setVantagePoint object.transform.position.x, object.transform.position.y
            @v.sweep()
            @othersVisibleAreas.push
              object: object
              area: @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      # calculate visibility for current player
      @v.AddSegments @object.renderer.segments
      @v.setVantagePoint @object.transform.position.x, @object.transform.position.y
      @v.sweep()
      @myVisibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      #if Input.GetButtonDown 'Use'
        # TODO: toggle flashlight
        # TODO: open doors/drawers
        # TODO: grab keys
        #console.log 'using'

    #Draw: (engine) ->
    #  ctx = engine.canvas.ctx
    #  ctx.lineWidth   = 1
    #  ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
    #  ctx.fillStyle   = 'rgba(255, 255, 255, .1)'

    #  # apply visible clipping mask
    #  traceSvgClippingArea ctx, @myVisibleArea

    #  ## draw hallway floors
    #  #ctx.fillRect 10, 10, @size-20, @size-20

    #  # draw my light
    #    
    #    # monster's 360-degree limited vision
    #    grd=ctx.createRadialGradient(@monster.x, @monster.y, 10, @monster.x, @monster.y, 200)
    #    grd.addColorStop(0, 'rgba(255,255,255,.1)')
    #    grd.addColorStop(1,'rgba(0,0,0,0)')
    #    ctx.fillStyle=grd
    #    ctx.fillRect 10, 10, @size-20, @size-20

    #    # apply others' clipping mask
    #    traceSvgClippingArea @player.visibleArea

    #    # draw player's 360-degree lantern light
    #    grd=ctx.createRadialGradient(@player.x, @player.y, 10, @player.x, @player.y, 300)
    #    grd.addColorStop(0, 'rgba(255,255,100,.3)')
    #    grd.addColorStop(1,'rgba(0,0,0,0)')
    #    ctx.fillStyle=grd
    #    ctx.fillRect 10, 10, @size-20, @size-20

    #  # draw other player
    #  ctx.beginPath()
    #  ctx.fillStyle = 'black'
    #  ctx.arc(@player.x, @player.y, 10, 0, Math.PI*2, true)
    #  ctx.fill()

    #  # TODO: draw props

    #  # lift other player clipping mask
    #  ctx.restore()

    #  # draw myself;
    #  # draw monster
    #  ctx.fillStyle = 'red'
    #  ctx.fillRect @monster.x, @monster.y, 20, 20

    #  # lift my clipping mask
    #  ctx.restore()



traceSvgClippingArea = (ctx, path) ->
  ctx.save()
  ctx.beginPath()
  i = 0
  while i < path.length
    if path[i] is "M"
      ctx.moveTo path[i + 1], path[i + 2]
      i += 2
    if path[i] is "L"
      ctx.lineTo path[i + 1], path[i + 2]
      i += 2
    i++
  ctx.clip()
