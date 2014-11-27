define -> class Transform
  constructor: ->
    @position = new Vector3
    @rotation = new Vector3
    @scale = new Vector3

  Translate: (vec3) ->

  Rotate: (vec3) ->

#transform = (h, p) ->
#  for matrix in h
#    [p.x, p.y, p.z] = dotProductVec4 [p.x, p.y, p.z, 1], matrix
#  return p


