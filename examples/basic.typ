#import "../main.typ" : dystac, dynamic, input

#dystac()

Here is some square at position x, y equal to
#input(name: "x", default: 1) and
#input(name: "y", default: 1).

#dynamic(variables : (x : 3, y : 1),
```typ

#import "@preview/cetz:0.3.4" : *
#canvas({
  import draw : *

  rect((0, 0), (rel: (10, 10)))
  rect((x, y), (rel: (1, 1)), stroke: 2pt + red)
})

```)
