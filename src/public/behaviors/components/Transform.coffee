define [
  '../lib/Vector3'
], (Vector3) -> class Transform
  constructor: ({ @parent }) ->
    # world
    @position = new Vector3
    @rotation = new Vector3
    @lossyScale = new Vector3

    # local
    @localPosition = new Vector3
    @localRotation = new Vector3
    @localScale = new Vector3

  Translate: (vec3) ->

  Rotate: (vec3) ->

#transform = (h, p) ->
#  for matrix in h
#    [p.x, p.y, p.z] = dotProductVec4 [p.x, p.y, p.z, 1], matrix
#  return p


