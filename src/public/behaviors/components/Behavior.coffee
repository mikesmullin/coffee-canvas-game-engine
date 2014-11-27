define -> class Behavior
  constructor: ->
    @enabled = true # enabled behaviors are updated, disabled are not

    # attachments
    #@animation = null
    #@audio = null
    #@camera = null
    #@collider2D = null
    #@light = null
    @renderer = null
    #@rigidbody2D = null
    @transform = null

  start: (cb) -> cb()
  update: ->
  draw: ->
