define [
  'lib/Vector3'
], (Vector3) -> class Transform
  constructor: ({ @object }) ->
    # world
    @position = new Vector3 0, 0, 0
    @rotation = new Vector3 0, 0, 0
    @lossyScale = new Vector3 1, 1, 1

    # local
    @localPosition = new Vector3 0, 0 ,0
    @localRotation = new Vector3 0, 0, 0
    @localScale = new Vector3 1, 1, 1

  Translate: (vec3) ->

  Rotate: (vec3) ->
