var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../components/Behavior', '../lib/GlTF'], function(Behavior, GlTF) {
  var World;
  return World = (function(_super) {
    __extends(World, _super);

    function World() {
      this.mapRoot = 'models/map1';
      this.map = 'map1.gltf';
    }

    World.prototype.startup = function() {
      var obj;
      obj = GlTF.InitMap(this.mapRoot, this.map);
      return this.renderer = new MeshRenderer(obj);
    };

    World.prototype.start = function() {};

    World.prototype.update = function() {};

    return World;

  })(Behavior);
});
