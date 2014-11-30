define -> class GMath
  @Rand: (m,x) -> Math.round(Math.random() * (x-m)) + m
  @Clamp: (value, min, max) ->
    if value > max then max else if value < min then min else value
  @Oscillate: (amplitude, period, x0, time) ->
    amplitude * Math.sin(time * 2 * Math.PI / period) + x0
  @Repeat: (t, length) -> t % length
