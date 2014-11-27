// Generated by CoffeeScript 1.7.1
(function() {
  define(function() {
    var Trig;
    return Trig = (function() {
      function Trig() {}

      Trig.degrees = 180 / Math.PI;

      Trig.Radian2Degrees = function(rad) {
        return rad * degrees;
      };

      Trig.Degrees2Radian = function(deg) {
        return deg / degrees;
      };

      Trig.GetRectAngle = function(x1, y1, x2, y2) {
        var asin, dist, distX, distY;
        distY = Math.abs(y2 - y1);
        distX = Math.abs(x2 - x1);
        dist = Math.sqrt((distY * distY) + (distX * distX));
        asin = Math.asin(distY / dist);
        return asin || 0;
      };

      return Trig;

    })();
  });

}).call(this);