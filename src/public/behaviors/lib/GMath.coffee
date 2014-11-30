define -> class GMath
  @rand: (m,x) -> Math.round(Math.random() * (x-m)) + m
  @clamp: (value, min, max) ->
    if value > max then max else if value < min then min else value
  @oscillate: (amplitude, period, x0, time) ->
    amplitude * Math.sin(time * 2 * Math.PI / period) + x0
