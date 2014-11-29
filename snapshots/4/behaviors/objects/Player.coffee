define [
  '../components/Behavior'
  '../components/BoxCollider'
], (Behavior, BoxCollider) ->
  class Player extends Behavior
    constructor: ->
      @user_id = null
      @name = null

      @collider = new BoxCollider

    @update: ->
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
            0, Math.cos(deg), -1 * Math.sin(deg), 0,
            0, Math.sin(deg), Math.cos(deg), 0,
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

