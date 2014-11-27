behaviors = []

define -> class Behavior
  constructor: (@gameObject) ->
    @enabled = true # enabled behaviors are updated, disabled are not

    @components = []

    # attachments
    @animation = null
    @audio = null
    @camera = null
    @collider2D = null
    @light = null
    @renderer = null
    @rigidbody2D = null
    @transform = null

    @id = behaviors.push this

  start: ->
  update: ->
  draw: ->
