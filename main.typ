#let dystac(
  content
) = {
  // context { if target() == "paged" { return content } }

  html.elem("script", attrs : (type: "module"),
  ```js
  import * as typst from "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst.ts/dist/esm/contrib/all-in-one-lite.bundle.js";

  function ready(fn) {
      if (document.readyState != "loading"){
          fn();
      } else {
          document.addEventListener("DOMContentLoaded", fn);
      }
  }
  window.ready = ready;

  function toTypstObject(x) {
    var obj = [];
    for (const k in x) {
      console.log("type : x[k]", typeof(x[k]));
      if (typeof(x[k]) == "number") {
        obj.push(`#let ${k} = ${x[k]}`);
      } else if (typeof(x[k]) == "string") {
        obj.push(`#let ${k} = \"${x[k]}\"`);
      }
    }
    return `${obj.join("\n")}`;
  }
  function makeSvg(variables, typst_code, id_svg) {
    const content = toTypstObject(variables) + "\n#set page(width: auto, height: auto, margin: 0em)\n" + typst_code;
    $typst.svg({ mainContent : content}).then(svg => {
      console.log("svg : ", svg);
      console.log("id : ", id_svg);
      const contentSvg = document.getElementById(id_svg);
      contentSvg.innerHTML = svg;

      /*
      const svgElem = contentSvg.firstElementChild;
      const width = Number.parseFloat(svgElem.getAttribute('width'));
      const height = Number.parseFloat(svgElem.getAttribute('height'));
      svgElem.removeAttribute('width');
      svgElem.removeAttribute('height');
      */
    });
  };
  window.makeSvg = makeSvg;
  // document.getElementById('typst').addEventListener('load', function () {
  $typst.setCompilerInitOptions({
      getModule: () =>
        'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm',
    });
  $typst.setRendererInitOptions({
      getModule: () =>
        'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm',
    });
   // })
  ```.text)

  content
}

#let input(
  name : "",
  default: 0
) = context {
  if target() == "paged" {
    return [#default]
  }

  html.elem("input", attrs : (
    id : name,
    type : "number",
    value : str(default),
  ))[]
}

#let to-js-object(object) = {
  let res = "{"
  for (key, value) in object {
    res += key + ":" + key + ".value,"
  }
  res += "}"
  res
}

#let to-typst-let-bindings(variables) = {
  let res = ""
  for (key, value) in variables {
    res += "let " + key + " = " + str(value) + "\n"
  }
  res
}

#let dynamic(
  variables : (),
  typst-code,
) = context {
  if target() == "paged" {
    return eval(to-typst-let-bindings(variables) + "[" + typst-code.text + "]")
  }

  let svg_id = "svg_id"

  for (name, value) in variables [
    #html.elem("script",
      name +
      ```js
      .addEventListener('input', function () {
        console.log('Input changed to:',
      ```.text +
      name +
      ".value);" +
      "ready(() => makeSvg(" +
        to-js-object(variables) + 
        ",`" + 
        typst-code.text + "`" +
        ",\"" +
        svg_id +
        "\"));" +
      "});"
    )
  ]
  html.elem("div", attrs : (id : svg_id))[]
}
