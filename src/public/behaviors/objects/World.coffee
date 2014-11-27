define [
  '../components/Behavior'
  '../lib/GlTF'
], (Behavior, GlTF) ->
  class World extends Behavior
    @mapRoot: 'models/map1'
    @map: 'map1.gltf'

    @start: (cb) ->
      GlTF.LoadMap @mapRoot, @map, cb, (name, h, fill_color, vertices) =>
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


        @renderer = new MeshRenderer obj
        cb()
