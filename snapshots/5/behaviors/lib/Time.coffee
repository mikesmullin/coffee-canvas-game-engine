define -> class Time
  @Now: -> (new Date()).getTime()
  @Delay: (s, f) -> setTimeout f, s
  @Interval: (s, f) -> setInterval f, s
