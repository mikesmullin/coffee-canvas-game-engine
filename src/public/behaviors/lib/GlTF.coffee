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

  @GetAttrVal: (mapRoot, data, accessor_id, cb) ->
    accessor = data.accessors[accessor_id]
    bufferView = data.bufferViews[accessor.bufferView]
    buffer = data.buffers[bufferView.buffer]

    a = (next) =>
      return next() if buffer.data
      @GetFile 'blob', "#{mapRoot}/#{buffer.uri}", (bin) ->
        if buffer.type is 'arraybuffer'
          reader = new FileReader
          reader.addEventListener 'loadend', ->
            buffer.data = reader.result
            next()
          reader.readAsArrayBuffer bin

    b = ->
      viewSlice = buffer.data.slice bufferView.byteOffset, bufferView.byteOffset + bufferView.byteLength
      attrSlice = viewSlice.slice accessor.byteOffset, accessor.byteOffset + ((accessor.byteStride or 1) * accessor.count)
      if accessor.type is 'VEC3'
        cb new Float32Array attrSlice
      else if accessor.type is 'SCALAR' and accessor.componentType is 5123
        cb new Uint16Array attrSlice

    a b

  @LoadMap: (mapRoot, map, done_cb, cb) ->
    @GetFile 'application/json', "#{mapRoot}/#{map}", (response) =>
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
            ((id, h, color) =>
              flow.serial (next) =>
                @GetAttrVal mapRoot, data, data.meshes[id].primitives[0].indices, (indices) =>
                  @GetAttrVal mapRoot, data, data.meshes[id].primitives[0].attributes.POSITION, (vertices) ->
                    cb data.meshes[id].name, h, color, vertices, indices, data.meshes[id].primitives[0].primitive
                    next()
            )(id, matrixHierarchy.slice(0), color)
          matrixHierarchy.pop()
      flow.go (err) ->
        done_cb()
