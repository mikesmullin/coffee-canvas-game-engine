define -> class MeshRenderer
  constructor: ({ @object }) ->
    @enabled = true
    #@castShadows = false
    #@receiveShadows = false
    @vertices = []
    @vcount = []
    @materials = [{}]

  Draw: (engine) ->
    ctx = engine.canvas.ctx
    ctx.lineWidth   = @materials[0].lineWidth or 2
    ctx.strokeStyle = @materials[0].strokeStyle or 'rgba(255, 255, 255, .1)'
    ctx.fillStyle   = @materials[0].fillStyle or 'rgba(255, 255, 255, .5)'

    pos = @object.transform.position

    ## apply Transform
    ## TODO: stop performing this on every draw
    ##        instead do it with Updates to Transform vectors
    #wv = [] # world vertices
    #for vec3 in @vertices
    #  wv.push( vec3.Clone()
    #    .RotateX @object.transform.rotation.x
    #    .Scale @object.transform.localScale
    #    .Add @object.transform.position
    #    #.RotateY @object.transform.rotation.y
    #    #.RotateZ @object.transform.rotation.z
    #    )
    wv = @vertices

    offset = 0
    for step in @vcount
      ctx.beginPath()
      ctx.moveTo wv[@indices[offset]].x, wv[@indices[offset]].y
      for i in [offset+2..offset+((step-1)*2)] by 2
        ctx.lineTo wv[@indices[i]].x, wv[@indices[i]].y
      offset = i
      ctx.closePath()
      ctx.fill()
      #ctx.stroke()
