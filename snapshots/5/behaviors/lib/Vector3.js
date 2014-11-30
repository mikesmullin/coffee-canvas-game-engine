// Generated by CoffeeScript 1.7.1
(function() {
  define(['lib/Trigonometry'], function(Trigonometry) {
    var Vector3;
    return Vector3 = (function() {
      function Vector3(x, y, z) {
        this.x = x != null ? x : 0;
        this.y = y != null ? y : 0;
        this.z = z != null ? z : 0;
      }

      Vector3.FromArray = function(a, i) {
        if (i == null) {
          i = 0;
        }
        return new Vector3(a[i], a[i + 1], a[i + 2]);
      };

      Vector3.back = {
        x: 0,
        y: 0,
        z: -1
      };

      Vector3.down = {
        x: 0,
        y: -1,
        z: 0
      };

      Vector3.forward = {
        x: 0,
        y: 0,
        z: 1
      };

      Vector3.left = {
        x: -1,
        y: 0,
        z: 0
      };

      Vector3.one = {
        x: 1,
        y: 1,
        z: 1
      };

      Vector3.right = {
        x: 1,
        y: 0,
        z: 0
      };

      Vector3.up = {
        x: 0,
        y: 1,
        z: 0
      };

      Vector3.zero = {
        x: 0,
        y: 0,
        z: 0
      };

      Vector3.prototype.TransformMatrix4 = function(b) {
        this.x = (this.x * b[0]) + (this.y * b[1]) + (this.z * b[2]) + (1 * b[3]);
        this.y = (this.x * b[4]) + (this.y * b[5]) + (this.z * b[6]) + (1 * b[7]);
        this.z = (this.x * b[8]) + (this.y * b[9]) + (this.z * b[10]) + (1 * b[11]);
        return this;
      };

      Vector3.prototype.RotateX = function(angle) {
        var nx, ny;
        nx = (this.x * Math.cos(angle)) - (this.y * Math.sin(angle));
        ny = (this.x * Math.sin(angle)) + (this.y * Math.cos(angle));
        this.x = nx;
        this.y = ny;
        return this;
      };

      Vector3.prototype.Dot = function(b) {
        return (this.x * b.x) + (this.y * b.y) + (this.z * b.z);
      };

      Vector3.prototype.Cross = function(b) {
        this.x = (this.y * b.z) - (this.z * b.y);
        this.y = (this.z * b.x) - (this.x * b.z);
        this.z = (this.x & b.y) - (this.y * b.x);
        return this;
      };

      Vector3.prototype.Scale = function(b) {
        this.x *= b.x;
        this.y *= b.y;
        this.z *= b.z;
        return this;
      };

      Vector3.prototype.Unit = function() {
        return this.Scale(this.one / this.Length());
      };

      Vector3.prototype.Add = function(b) {
        this.x += b.x;
        this.y += b.y;
        this.z += b.z;
        return this;
      };

      Vector3.prototype.Subtract = function(b) {
        this.x -= b.x;
        this.y -= b.y;
        this.z -= b.z;
        return this;
      };

      Vector3.prototype.Copy = function(b) {
        this.x = b.x;
        this.y = b.y;
        this.z = b.z;
        return this;
      };

      Vector3.prototype.Clone = function() {
        return new Vector3(this.x, this.y, this.z);
      };

      Vector3.prototype.Length = function() {
        return Math.sqrt(this.Dot(this));
      };

      return Vector3;

    })();
  });

}).call(this);
