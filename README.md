Coffee Canvas Game Engine
=========================

Features:

* Mimics [Unity3D API](http://docs.unity3d.com/ScriptReference/) in [CoffeeScript](http://coffeescript.org).
* Uses [RequireJS](http://requirejs.org) to load dependencies between its object-oriented file structure.
* Optionally compiles to [HTML5](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/HTML5) + [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript) format good for statically-hosted single-player games.
* Includes [Node.JS](http://nodejs.org) + [Websocket](https://developer.mozilla.org/en-US/docs/WebSockets)-powered multiplayer game server. All traffic goes over tcp/80; bypasses firewalls/proxies!
* Imports [Blender](http://blender.org) models via export to [COLLADA](http://collada.org) and the new official Khronos Group JSON-based [glTF](https://github.com/KhronosGroup/glTF/blob/master/specification/README.md) 3D format.
* Works in all major browsers on desktop as well as mobile devices--especially [iPad](https://www.apple.com/ipad/) and [Android](https://www.android.com/).
* Supports mouse capture as well as multi-touch input devices.
* Supports both 2D and 3D modes with [Canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API).

Code is here:

* [`src/public/behaviors/global.coffee`](src/public/behaviors/global.coffee) Bootstrap
* [`src/public/behaviors/objects/Cube.coffee`](src/public/behaviors/objects/Cube.coffee) Sample Cube game object
* [`src/public/behaviors/Engine.coffee`](src/public/behaviors/Engine.coffee) Engine
* [`src/web.coffee`](src/web.coffee) Sample Room-based Multiplayer server logic

Statically-hosted demos:

* [Demo 1: Simple maze game](http://mikesmullin.github.io/coffee-canvas-game-engine/)
* [Demo 2: Transformations](http://mikesmullin.github.io/coffee-canvas-game-engine/snapshots/2)
* [Demo 3: Visibility and lighting](http://mikesmullin.github.io/coffee-canvas-game-engine/snapshots/3)
* [Demo 4: Perspective light and shadow](http://mikesmullin.github.io/coffee-canvas-game-engine/snapshots/4)
* [Demo 5: Seeker game](http://mikesmullin.github.io/coffee-canvas-game-engine/snapshots/5)
* [Demo 6: Hider game](http://mikesmullin.github.io/coffee-canvas-game-engine/snapshots/6)
