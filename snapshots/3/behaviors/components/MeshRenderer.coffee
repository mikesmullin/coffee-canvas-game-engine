define -> class MeshRenderer
  constructor: ({ @object }) ->
    @enabled = true
    #@castShadows = false
    #@receiveShadows = false
    @arrayType = 'triangles'
    @vertices = []
    @materials = [{}]

  Draw: (engine) ->
    ctx = engine.canvas.ctx
    ctx.lineWidth   = @materials[0].lineWidth or 1
    ctx.strokeStyle = @materials[0].strokeStyle or 'rgba(255, 255, 255, .8)'
    ctx.fillStyle   = @materials[0].fillStyle or 'rgba(255, 255, 255, .5)'

    pos = @object.transform.position

    # apply Transform
    # TODO: stop performing this on every draw
    #        instead do it with Updates to Transform vectors
    wv = [] # world vertices
    for vec3 in @vertices
      wv.push( vec3.Clone()
        .RotateX @object.transform.rotation.x
        .Scale @object.transform.localScale
        .Add @object.transform.position
        #.RotateY @object.transform.rotation.y
        #.RotateZ @object.transform.rotation.z
        )

    step = switch @arrayType
      when 'triangles' then 3
      when 'quads' then 4

    for nil, i in wv by step
        ctx.beginPath()
        ctx.moveTo wv[i].x,   wv[i].y
        ctx.lineTo wv[i+1].x, wv[i+1].y
        ctx.lineTo wv[i+2].x, wv[i+2].y
        if @arrayType is 'quads'
          ctx.lineTo wv[i+3].x, wv[i+3].y
        ctx.closePath()
        ctx.fill()
        ctx.stroke()
