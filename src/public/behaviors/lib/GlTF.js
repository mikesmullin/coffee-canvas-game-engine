define(['async2'], function(async) {
  var GlTF;
  return GlTF = (function() {
    function GlTF() {}

    GlTF.GetFile = function(type, url, cb) {
      var xhr;
      xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function() {
        if (this.readyState === 4 && this.status === 200) {
          return cb(this.response);
        }
      };
      xhr.open('GET', url);
      xhr.responseType = type;
      return xhr.send();
    };

    GlTF.GetAttrVal = function(data, accessor_id, cb) {
      var a, accessor, b, buffer, bufferView;
      accessor = data.accessors[accessor_id];
      bufferView = data.bufferViews[accessor.bufferView];
      buffer = data.buffers[bufferView.buffer];
      a = function(next) {
        if (buffer.data) {
          return next();
        }
        return getFile('blob', "" + mapRoot + "/" + buffer.uri, function(bin) {
          var reader;
          if (buffer.type === 'arraybuffer') {
            reader = new FileReader;
            reader.addEventListener('loadend', function() {
              buffer.data = reader.result;
              return next();
            });
            return reader.readAsArrayBuffer(bin);
          }
        });
      };
      b = function() {
        var attrSlice, viewSlice;
        viewSlice = buffer.data.slice(bufferView.byteOffset, bufferView.byteOffset + bufferView.byteLength);
        attrSlice = viewSlice.slice(accessor.byteOffset, accessor.byteOffset + (accessor.byteStride * accessor.count));
        switch (accessor.type) {
          case 'VEC3':
            return cb(new Float32Array(attrSlice));
        }
      };
      return a(b);
    };

    GlTF.LoadMap = function(map, done_cb, cb) {
      return getFile('application/json', map, function(response) {
        var child, color, data, flow, id, matrixHierarchy, node, rgba, _fn, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
        data = JSON.parse(response);
        flow = new async;
        matrixHierarchy = [];
        _ref = data.scenes[data.scene].nodes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          matrixHierarchy.push(data.nodes[node].matrix);
          _ref1 = data.nodes[node].children;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            child = _ref1[_j];
            matrixHierarchy.push(data.nodes[child].matrix);
            _ref2 = data.nodes[child].meshes;
            _fn = function(id, h, color) {
              return flow.serial(function(next) {
                return getAttrVal(data, data.meshes[id].primitives[0].attributes.POSITION, function(vertices) {
                  cb(data.meshes[id].name, h, color, vertices);
                  return next();
                });
              });
            };
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              id = _ref2[_k];
              color = '';
              rgba = (_ref3 = data.materials[data.meshes[id].primitives[0].material].instanceTechnique.values) != null ? _ref3.diffuse : void 0;
              color = "rgba(" + (Math.ceil(60 + (255 * rgba[0]))) + ", " + (Math.ceil(30 + (255 * rgba[1]))) + ", " + (Math.ceil(0 + (255 * rgba[2]))) + ", " + (Math.round(rgba[3], 1)) + ")";
              _fn(id, matrixHierarchy.slice(0), color);
            }
            matrixHierarchy.pop();
          }
        }
        return flow.go(function(err) {
          return done_cb();
        });
      });
    };

    GlTF.InitMap = function(map, cb) {
      return loadMap("" + mapRoot + "/" + map, cb, function(name, h, fill_color, vertices) {
        var i, local, nil, object, p, world, xmax, xmin, ymax, ymin, zmax, zmin, _i, _len;
        object = {
          name: name,
          vertices: [],
          fill: fill_color,
          x: null,
          y: null,
          z: null,
          xT: 0,
          yT: 0,
          zT: 0,
          width: null,
          height: null,
          depth: null,
          min: [null, null, null],
          max: [null, null, null]
        };
        world = h[0], local = h[1];
        h = [local, world, [1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [35, 0, 0, 0, 0, 35, 0, 0, 0, 0, 35, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 180, 320, 0, 1]];
        xmin = ymin = zmin = xmax = ymax = zmax = null;
        for (i = _i = 0, _len = vertices.length; _i < _len; i = _i += 3) {
          nil = vertices[i];
          p = transform(h, {
            x: vertices[i],
            y: vertices[i + 1],
            z: vertices[i + 2]
          });
          xmin = Math.min(p.x, null === xmin ? p.x : xmin);
          ymin = Math.min(p.y, null === ymin ? p.y : ymin);
          zmin = Math.min(p.z, null === zmin ? p.z : zmin);
          xmax = Math.max(p.x, null === xmax ? p.x : xmax);
          ymax = Math.max(p.y, null === ymax ? p.y : ymax);
          zmax = Math.max(p.z, null === zmax ? p.z : zmax);
          object.vertices.push(p);
        }
        object.min = [xmin, ymin, zmin];
        object.max = [xmax, ymax, zmax];
        object.width = xmax - xmin;
        object.height = ymax - ymin;
        object.depth = zmax - zmin;
        object.x = 0;
        object.y = 0;
        object.z = 0;
        objects[name] = object;
        return console.log(object);
      });
    };

    return GlTF;

  })();
});
