define -> class Time
  @now: -> (new Date()).getTime()
  @delay: (s, f) -> setTimeout f, s
