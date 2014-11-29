define -> class BoxCollider
  constructor: ->
    @enabled = true
    @is_trigger = false
    @center = x: 0, y: 0, z: 0
    @size = x: 0, y: 0, z: 0

  Update: ->
    # check player collision
    for name in ['player1', 'player2']
      obj = objects[name]
      if obj.lastX and obj.targetX and obj.lastY and obj.targetY
        rad = getAngle obj.lastX, obj.lastY, obj.targetX, obj.targetY
        deg = rad2deg rad
        console.log name: name, deg: deg

        # rotate player
        rot = [
          1, 0, 0, 0,
          0, Math.cos(deg), -1 * Math.sin(deg), 0
          0, Math.sin(deg), Math.cos(deg), 0
          0, 0, 0, 1
        ]
        for nil, i in obj.vertices
          obj.vertices[i] = transform rot, obj.vertices[i]

      obj.lastX = obj.targetX = obj.lastY = obj.targetY = null

      if obj.xT or obj.yT
        if collidesWith obj, objects['wall']
          console.log 'collide'
        else if collidesWith obj, objects[if whoami is 'player1' then 'player2' else 'player1']
          console.log 'collide'
          #alert 'game over!'
          #location.reload()
        else
          obj.x += obj.xT
          obj.y += obj.yT
          if MULTIPLAYER
            socket.send JSON.stringify pm: [myid, obj.x, obj.y]
        obj.xT = obj.yT = obj.zT = 0


  @collidesWith: (a, b) ->
    for nil, i in a.vertices by 3
      aT = [{
        x: a.vertices[i].x + a.x + a.xT
        y: a.vertices[i].y + a.y + a.yT
      },{
        x: a.vertices[i+1].x + a.x + a.xT
        y: a.vertices[i+1].y + a.y + a.yT
      },{
        x: a.vertices[i+2].x + a.x + a.xT
        y: a.vertices[i+2].y + a.y + a.yT
      }]
      for nil, ii in b.vertices by 3
        bT = [{
          x: b.vertices[ii].x + b.y
          y: b.vertices[ii].y + b.y
        },{
          x: b.vertices[ii+1].x + b.x
          y: b.vertices[ii+1].y + b.y
        },{
          x: b.vertices[ii+2].x + b.x
          y: b.vertices[ii+2].y + b.y
        }]
        if trianglesIntersect aT, bT
          return true
    return false

  @trianglesIntersect: (a, b) ->
    # cheating by converting them to rectangles
    # because they're always at 90 degree angles right now
    l1x = Math.min a[0].x, a[1].x, a[2].x
    r1x = Math.max a[0].x, a[1].x, a[2].x
    l1y = Math.max a[0].y, a[1].y, a[2].y
    r1y = Math.min a[0].y, a[1].y, a[2].y
    l2x = Math.min b[0].x, b[1].x, b[2].x
    r2x = Math.max b[0].x, b[1].x, b[2].x
    l2y = Math.max b[0].y, b[1].y, b[2].y
    r2y = Math.min b[0].y, b[1].y, b[2].y

    return false if l1x > r2x || l2x > r1x # aside
    return false if l1y < r2y || l2y < r1y # above or below
    return true
