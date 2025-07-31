#let dystac() = {
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
      obj.push(`#let ${k} = ${x[k]};\n`);
    }
    return `${obj.join("")}`;
  }

  function makeSvg(variables, typst_code, id_svg) {
    console.log("init typst code :\n", typst_code);
    const content = "\n#set page(width: auto, height: auto, margin: 0em)\n" + toTypstObject(variables) + typst_code;
    console.log("typst code :\n", content);
    $typst.svg({ mainContent : content}).then(svg => {
      const contentSvg = document.getElementById(id_svg);
      contentSvg.innerHTML = svg;
    });
  };
  window.makeSvg = makeSvg;
  $typst.setCompilerInitOptions({
      getModule: () =>
        'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm',
    });
  $typst.setRendererInitOptions({
      getModule: () =>
        'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm',
    });
  ```.text)
}

#let input(
  name : "",
  default: 0,
  type_input : "number"
) = context {
  if target() == "paged" {
    return [#default]
  }

  html.elem("input", attrs : (
    id : name,
    type : type_input,
    value : str(default),
  ))[]
}

#let to-js-object(object) = {
  "{" + object.pairs().map(((key, value)) => {
    key + ":" + key + ".value"}
  ).join(", \n") + "}"
}

#let to-typst-let-bindings(variables) = {
  variables.pairs().map(((key, value)) => {
    if type(value) == int {
      "let " + key + " = " + str(value) + "\n"
    } else if type(value) == str {
      "let " + key + " = \"" + str(value) + "\"\n"
    }
  }).join("")
}

#let type-to-string(t) = {
  if type(t) == int { return "int" }
  else if type(t) == string { return "string" }
  else if type(t) == dictionay { return "dictionary" }
}

#let dynamic(
  variables : (:),
  typst-code,
) = context {
  if target() == "paged" {
    return eval(to-typst-let-bindings(variables) + "[\n" + typst-code.text + "\n]")
  }

  let svg_id = "svg_id"

  let make_svg_code = "makeSvg(" + to-js-object(variables) + ",`" + typst-code.text + "`" + ",\"" + svg_id + "\")"

  for (name, value) in variables [
    #html.elem("script",
      name +
      ```js
      .addEventListener('input', function () {
        console.log('Input changed to:',
      ```.text +
      name +
      ".value);\n" + "ready(() => " + make_svg_code + ");\n" + "});"
    )
  ]
  html.elem("div", attrs : (id : svg_id))[]
}
