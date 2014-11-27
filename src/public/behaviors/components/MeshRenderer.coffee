define -> class MeshRenderer
  constructor: ({ @object }) ->
    @enabled = true
    #@castShadows = false
    #@receiveShadows = false
    @arrayType = 'triangles'
    @vertices = []
    @materials = [{
      color: 'white'
    }]

  Draw: (engine) ->
    ctx = engine.canvas.ctx
    ctx.lineWidth   = @materials[0].lineWidth or 1
    ctx.strokeStyle = @materials[0].strokeStyle or 'rgba(255, 255, 255, .8)'
    ctx.fillStyle   = @materials[0].fillStyle or 'rgba(255, 255, 255, .5)'

    pos = @object.transform.position

    step = switch @arrayType
      when 'triangles' then 3
      when 'quads' then 4

    for nil, i in @vertices by step
        ctx.beginPath()
        ctx.moveTo @vertices[i].x+pos.x,   @vertices[i].y+pos.y
        ctx.lineTo @vertices[i+1].x+pos.x, @vertices[i+1].y+pos.y
        ctx.lineTo @vertices[i+2].x+pos.x, @vertices[i+2].y+pos.y
        if @arrayType is 'quads'
          ctx.lineTo @vertices[i+3].x+pos.x, @vertices[i+3].y+pos.y
        ctx.closePath()
        ctx.fill()
        ctx.stroke()
