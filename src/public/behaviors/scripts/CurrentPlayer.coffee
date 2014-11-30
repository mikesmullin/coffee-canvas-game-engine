define [
  'components/Script'
  'scripts/TopDownController2D'
  'lib/Input'
  'lib/Visibility'
  'lib/Geometry'
], (Script, TopDownController2D, Input, {Visibility}, {Point, Segment}) ->
  class CurrentPlayer extends Script
    constructor: ->
      super
      @object.BindScript TopDownController2D
      @v = new Visibility

    OnControllerColliderHit: (engine, collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"

    Update: (engine) ->
      @v.ResetSegments()
      object = getWall engine
      parse_segments object
      @v.AddSegments object.renderer.segments

      # calculate visibility for other players
      for object in getOtherPlayers engine, @object
        parse_segments object
        #@v.AddSegments object.renderer.segments
        {x,y} = getObjectCoords object
        @v.SetVantagePoint x, y
        @v.Sweep()
        object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      # calculate visibility for current player
      parse_segments @object
      #@v.AddSegments @object.renderer.segments
      {x,y} = getObjectCoords @object
      @v.SetVantagePoint x, y
      @v.Sweep()
      @object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

    Draw: (engine) ->
      ctx = engine.canvas.ctx

      # apply visible clipping mask
      traceSvgClippingArea ctx, @object.visibleArea

      ## apply slight glow to hallway floors
      #ctx.fillStyle = 'rgba(255,255,255,0.1)'
      #ctx.fillRect 0, 0, size, size

      # draw walls
      #object = getWall engine
      #ctx.lineWidth   = 1
      #ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
      #ctx.fillStyle   = 'rgba(255, 255, 255, .1)'
      #draw_segments ctx, object

      # draw my light
      drawPlayerLight ctx, @object, @object

      # draw myself
      #draw_segments ctx, @object
      draw_vertices ctx, @object

      unless @object.constructor.name is 'Monster' and not @object.visible # monster cant see other players when invisible
        # draw other players
        for object in getOtherPlayers engine, @object
          unless object.constructor.name is 'Monster' and not object.visible # other players cannot see monster when its invisible
            # apply other player's clipping mask
            traceSvgClippingArea ctx, object.visibleArea

            # draw other player's light
            drawPlayerLight ctx, object, @object

            # draw other player
            # TODO: actually draw imported player model. but i need to make it black. also walls need to be made black
            ctx.beginPath()
            ctx.fillStyle = 'black'
            {x,y} = getObjectCoords object
            ctx.arc(x, y, 10, 0, Math.PI*2, true)
            #draw_vertices ctx, object
            ctx.fill()

            # lift other player's clipping mask
            ctx.restore()

      # TODO: draw props

      # lift my clipping mask
      ctx.restore()



  getWall = (engine) ->
    for object in engine.objects when object.constructor.name is 'Wall'
      return object

  getOtherPlayers = (engine, me) ->
    players = []
    for object in engine.objects
      if ((object.constructor.name is 'Player' or
        object.constructor.name is 'Monster') and
        object.enabled and
        object isnt me)
          players.push object
    return players

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

  transformed_vertices = (object) ->
    # apply Transform
    # TODO: stop performing this on every draw
    #        instead do it with Updates to Transform vectors
    wv = [] # world vertices
    for vec3 in object.renderer.vertices
      wv.push( vec3.Clone()
        #.RotateX @object.transform.rotation.x
        #.Scale @object.transform.localScale
        .Add object.transform.position
        #.RotateY @object.transform.rotation.y
        #.RotateZ @object.transform.rotation.z
        )
    return wv

  parse_segments = (object) ->
    wv = transformed_vertices object
    object.renderer.segments = []
    offset = 0
    indices = object.renderer.indices
    for step in object.renderer.vcount
      x0 = x = wv[indices[offset]].x
      y0 = y = wv[indices[offset]].y
      p1 = new Point x, y
      for i in [offset+2..offset+((step-1)*2)] by 2
        x = wv[indices[i]].x
        y = wv[indices[i]].y
        p2 = new Point x, y
        object.renderer.segments.push new Segment p1, p2
        p1 = new Point x, y
      offset = i
      p2 = new Point x0, y0
      object.renderer.segments.push new Segment p1, p2

  draw_segments = (ctx, object) ->
    for seg in object.renderer.segments
      ctx.beginPath()
      ctx.moveTo seg.p1.x, seg.p1.y
      ctx.lineTo seg.p2.x, seg.p2.y
      ctx.stroke()

  draw_vertices = (ctx, object) ->
    ctx.lineWidth   = object.renderer.materials[0].lineWidth
    ctx.strokeStyle = object.renderer.materials[0].strokeStyle
    ctx.fillStyle   = object.renderer.materials[0].fillStyle
    wv = transformed_vertices object
    offset = 0
    indices = object.renderer.indices
    for step in object.renderer.vcount
      ctx.beginPath()
      x0 = x = wv[indices[offset]].x
      y0 = y = wv[indices[offset]].y
      ctx.moveTo x, y
      for i in [offset+2..offset+((step-1)*2)] by 2
        x = wv[indices[i]].x
        y = wv[indices[i]].y
        ctx.lineTo x, y
      offset = i
      ctx.closePath()
      ctx.fill()

  getObjectCoords = (object) ->
    x: object.renderer.vertices[0].x + object.transform.position.x
    y: object.renderer.vertices[0].y + object.transform.position.y

  size = 640

  drawPlayerLight = (ctx, object, me) ->
    {x, y} = getObjectCoords object
    if object.constructor.name is 'Monster'
      if object is me
        # monster's 360-degree limited vision
        grd=ctx.createRadialGradient(x, y, 10, x, y, 200)
        grd.addColorStop(0, 'rgba(255,255,255,.1)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size

    else if object.constructor.name is 'Player'
      if object.flashlightLit
        # draw player's 360-degree lantern light
        grd=ctx.createRadialGradient(x, y, 10, x, y, 300)
        grd.addColorStop(0, 'rgba(255,255,100,.3)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size
      else if object is me
        # 360-degree limited vision
        grd=ctx.createRadialGradient(x, y, 10, x, y, 200)
        grd.addColorStop(0, 'rgba(255,255,255,.1)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size
      else
        # monster will see no light from player with flashlight off
        # only their black dot moving against dark gray floor

  return CurrentPlayer
