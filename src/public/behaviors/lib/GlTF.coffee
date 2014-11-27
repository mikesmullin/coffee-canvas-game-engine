define [
  'async2'
], (async) -> class GlTF
  @GetFile: (type, url, cb) ->
    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if @readyState is 4 and @status is 200
        cb @response
    xhr.open 'GET', url
    xhr.responseType = type
    xhr.send()

  @GetAttrVal: (data, accessor_id, cb) ->
    accessor = data.accessors[accessor_id]
    bufferView = data.bufferViews[accessor.bufferView]
    buffer = data.buffers[bufferView.buffer]

    a = (next) ->
      return next() if buffer.data
      getFile 'blob', "#{mapRoot}/#{buffer.uri}", (bin) ->
        if buffer.type is 'arraybuffer'
          reader = new FileReader
          reader.addEventListener 'loadend', ->
            buffer.data = reader.result
            next()
          reader.readAsArrayBuffer bin

    b = ->
      viewSlice = buffer.data.slice bufferView.byteOffset, bufferView.byteOffset + bufferView.byteLength
      attrSlice = viewSlice.slice accessor.byteOffset, accessor.byteOffset + (accessor.byteStride * accessor.count)
      switch accessor.type
        when 'VEC3'
          cb new Float32Array attrSlice

    a b

  @LoadMap: (map, done_cb, cb) ->
    getFile 'application/json', map, (response) ->
      data = JSON.parse response
      flow = new async
      matrixHierarchy = []
      for node in data.scenes[data.scene].nodes
        matrixHierarchy.push data.nodes[node].matrix
        for child in data.nodes[node].children
          matrixHierarchy.push data.nodes[child].matrix
          for id in data.nodes[child].meshes
            color = ''
            rgba = data.materials[data.meshes[id].primitives[0].material].instanceTechnique.values?.diffuse
            color = "rgba(#{Math.ceil 60+(255*rgba[0])}, #{Math.ceil 30+(255*rgba[1])}, #{Math.ceil 0+(255*rgba[2])}, #{Math.round rgba[3], 1})"
            ((id, h, color) ->
              flow.serial (next) ->
                getAttrVal data, data.meshes[id].primitives[0].attributes.POSITION, (vertices) ->
                  cb data.meshes[id].name, h, color, vertices
                  next()
            )(id, matrixHierarchy.slice(0), color)
          matrixHierarchy.pop()
      flow.go (err) ->
        done_cb()


  @InitMap: (map, cb) ->
    loadMap "#{mapRoot}/#{map}", cb, (name, h, fill_color, vertices) ->
      # push all vertices into a new game object
      object =
        name: name
        vertices: []
        fill: fill_color
        x: null
        y: null
        z: null
        xT: 0
        yT: 0
        zT: 0
        width: null
        height: null
        depth: null
        min: [null,null,null]
        max: [null,null,null]

      [world, local] = h
      h = [
        local

        world

        ## rotate to top orthogonal perspective
        # this doesn't work perfectly because its rotating around an arbitrary origin
        # so for now i rotate everything in blender first, instead
        #[
        #  1, 0, 0, 0,
        #  0, Math.cos(90), -1 * Math.sin(90), 0,
        #  0, Math.sin(90), Math.cos(90), 0,
        #  0, 0, 0, 1
        #]

        # flip along x-axis
        [
          1, 0, 0, 0
          0, -1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1
        ]

        # and zoom to fit canvas
        [
          35, 0, 0, 0
          0, 35, 0, 0,
          0, 0, 35, 0,
          0, 0, 0, 1
        ]

        # center
        [
          1, 0, 0, 0
          0, 1, 0, 0,
          0, 0, 1, 0,
          180, 320, 0, 1
        ]

      ]

      xmin = ymin = zmin = xmax = ymax = zmax = null
      for nil, i in vertices by 3
        p = transform h, {
          x: vertices[i]
          y: vertices[i+1]
          z: vertices[i+2]
        }
        xmin = Math.min p.x, if null is xmin then p.x else xmin
        ymin = Math.min p.y, if null is ymin then p.y else ymin
        zmin = Math.min p.z, if null is zmin then p.z else zmin
        xmax = Math.max p.x, if null is xmax then p.x else xmax
        ymax = Math.max p.y, if null is ymax then p.y else ymax
        zmax = Math.max p.z, if null is zmax then p.z else zmax
        object.vertices.push p

      object.min = [xmin, ymin, zmin]
      object.max = [xmax, ymax, zmax]
      object.width = xmax - xmin
      object.height = ymax - ymin
      object.depth = zmax - zmin
      object.x = 0
      object.y = 0
      object.z = 0

      objects[name] = object
      console.log object

