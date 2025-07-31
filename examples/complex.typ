#import "../dystac.typ" : dystac, input, dynamic
#import "@preview/cetz:0.3.4" : canvas, draw, tree

#let frame_if_html(content) = context {
  if target() == "paged" {
    content
  } else {
    html.frame(content)
  }
}

#show math.equation: it => frame_if_html(it)
#show block : it => frame_if_html(it)

// #set page(numbering : "1-1")

#let display_tree_codage(data)={
canvas(
  length: 0.7cm, {
  import draw: *
  set-style(
    stroke : 0.8pt,
    content: (frame: "circle", stroke: none, fill: white, padding: 0.0000001))
  tree.tree(
    data,
    spread: 1,
    grow: 1.3,
    draw-node: (node, ..) => {
      content((), node.content)
    },
    draw-edge: (from, to, ..) => {
    line((a: from, number: .0, b: to),
         (a: to, number: .2, b: from), mark: (end: ">"), name : "line")
    if to.last() == "0" {
      content("line.mid", [1])
    } else {
      content("line.mid", [0])
    }
    }
  )
})
}

#let codage_arith(
  distrib,
  message,
  h : 0.06,
  decodage : none,
  length : 18cm,
  prec : 5
)={
canvas(
  length: length,
  {
import draw: *

if message != "" {
  content((h,h * 1.4), [message : #message])
}
content((1 - 0.01, h + h / 5), [EOF])
let draw_interval(posh, begin, end, h)={
  let transform = end - begin
  let offset = begin
  line((begin, posh), (end, posh)) // horizontal axe
  line((begin, posh), (begin, h + posh)) // left vertical line
  for (i, (letter, proba)) in distrib.enumerate() {
    proba *= transform
    offset += proba
    line((offset, posh), (offset, h + posh))
    if end - begin >= 0.04 {
      content((offset - proba / 2, h / 2 + posh), letter)
    }
  }
}

draw_interval(0, 0, 1, h)

let previous_begin = 0
let previous_end = 1

for i in range(message.len()) {
  let letter = message.at(i)

  let end = 0
  let begin = 0
  for (l, proba) in distrib {
    if letter == l {
      end = begin + proba
      break
    }
    begin += proba
  }
  let factor = end - begin
  begin = previous_begin + begin * (previous_end - previous_begin)
  end = previous_begin + end * (previous_end - previous_begin)
  draw_interval(- (i + 1) * h, begin, end, h)
  previous_begin = begin
  previous_end = end
  content(
    (begin - length.pt() / 25000, - h * (i + 1) - h / 8), 
    text(8pt, str(begin).slice(0, calc.min(int(prec),str(begin).len())))
  )
  if end - begin >= 0.03 {
    content(
      (end + length.pt() / 25000, - h * (i + 1) - h / 8), 
      text(8pt, str(end).slice(0, calc.min(int(prec),str(end).len())))
    )
  }
  if i != 0 {
    prec += 1 / i
  }
}
if decodage != none {
  line((decodage, h), (decodage, - message.len() * h), stroke : red + 0.7pt)
  content((decodage, h + h / 2), [#decodage])
}
})
}

#let codage_arith_compute(
  distrib,
  message,
)={
let previous_begin = 0
let previous_end = 1
for i in range(message.len()) {
  let letter = message.at(i)

  let end = 0
  let begin = 0
  for (l, proba) in distrib {
    if letter == l {
      end = begin + proba
      break
    }
    begin += proba
  }
  let factor = end - begin
  begin = previous_begin + begin * (previous_end - previous_begin)
  end = previous_begin + end * (previous_end - previous_begin)
  previous_begin = begin
  previous_end = end
  if letter == "$" {

    return (begin, end)
  }
}
}


#align(center)[
  #set text(30pt, weight: "black")
  Devoirs Maison \ Théorie de l'Information
]

#align(center)[
  #set text(15pt)
  Paul ADAM - Gaëtan REGAUD
]

#set heading(numbering: (..nums) => {
  let (i, num) = nums.pos().enumerate().last()
  if i == 0 {
    numbering("1.", num)
  } else if i == 1 {
    numbering("a.", num)
  } else if i == 2 {
    numbering("1.", num)
  }
})

#show heading.where(level: 1): it => {
  set text(22pt, weight: 600) 
  block(inset: (left : 15pt, top : 5pt, bottom : 5pt))[#it]
}

#show heading.where(level: 2): it => {
  box(inset : (right: 3pt))[#it]  
}


= Calcul Entropique

==
$I(Y; Z | X) = H(Y | X) - H(Y | X , Z) =  2 + alpha - 2 = alpha $

==
$H(Z | Y) = H(Z) - I(Y; Z) = 7 - 1 = 6$

==
$H(Z | X) = H(Z) - I(X; Z) = 7 - 2 = 5$

==
// $
// I(X; Z | Y) & = H(X | Y) + H(Z | Y) - H(X,Z | Y) \
// & = H(X | Y) + H(Z | Y) - (H(Z) - I(X; Z) - I(Y; Z | X)) - H(X | Y) \
// & = H(Z | Y) - H(Z) + I(X; Z) + I(Y; Z | X) \
// & = 6 - 7 + 2 + alpha \
// & = 1 + alpha \
// $
//
$
I(X; Z | Y) & = H(Z) - I(Y; Z) - H(Z | X, Y) \
& = H(Z) - I(Y; Z) - (H(Z) - I(X; Z) - I(Y; Z | X))\
& = - I(Y; Z) + I(X; Z) + I(Y; Z | X)\
& = - 1 + 2 + alpha \
& = 1 + alpha \
$

==
$H(Z | X, Y) = H(Z) - I(X; Z) - I(Y; Z | X) = 7 - 2 - alpha = 5 - alpha$

==
$H(X | Y, Z) = H(X | Y) - I(X; Z | Y) = 4 - 1 - alpha = 3 - alpha $

==
$I(X; Y | Z) = H(X) - H(X | Y, Z) - I(X; Z) = 3 + beta - 3 + alpha - 2 = beta + alpha - 2 $

==
$H(X, Y, Z) = H(X) + H(Y|X) + H(Z | Y, X) = 3 + beta + 2 + alpha + 5 - alpha = 10 + beta $

==
On a tout d'abord : 
- a. donne $alpha >= 0$
- d. donne $alpha >= -1$
- e. donne $alpha <= 5$
- f. donne $alpha <= 3$
- h. donne $beta >= - 10$

Donc au moins $alpha in [0, 3]$ et $beta in [-10, +infinity[  $

- g. nous donne donc, 
$
& beta + alpha - 2 >= 0 \
& => beta >= 2 - alpha \
& => beta >= 2 - 3 = - 1
$

$
I(X; Y) = H(X) - H(X | Y) = 3 + beta - 4 = beta - 1 >= 0 
$
Donc $beta >= 1$

Conclusion : $alpha in [0, 3]$ et $beta in [1, +infinity[  $

==
On a tout d'abord : $X "et" Y "independant" <==> I(X, Y) = 0 <==> beta = 1$.

$"Sachant" Z, X "et" Y "independant" <==> I(X, Y | Z) = 0 <==> beta + alpha = 2$

==
#text(11pt)[#align(center)[
#canvas(
  length : 0.06cm,
  {
  import draw: *
  circle((50,75), radius : 90) 
  circle((0,0), radius : 90) 
  circle((100,0), radius : 90)
  
  content((175, -60), $H(X) = 3 + beta$, angle: 45deg)
  content((130, 125), $H(Z) = 7$, angle : -53deg)
  content((-30, -30), $H(Y | X , Z) = 2$)
  content((-25, 18), $H(Y | X) = 2 + alpha$, angle: -50deg)
  content((128, 20), $H(X | Y) = 4$, angle : 50deg)
  content((77, 35), $I(X ; Z) = 2 $, angle: -65deg)
  content((10, 30), $I(Y ; Z) = 1$, angle : 70deg)
  content((0, 60), $I(Y ; Z | X) = alpha$)
  content((85, 92), $H(Z | Y) = 6 $, angle: 10deg)
  content((15, 93), $H(Z | X) =5$, angle : -10deg)
  content((105, 60), $I(X ; Z | Y) = 1 + alpha $)
  content((50, -35), $I(X ; Y | Z) = \ beta + alpha - 2 $)
  content((160, 160), $H(X, Y, Z) = beta + 10$)
  content((140, -20), $H(X | Y, Z) = 3 - alpha$)
  content((50, 130), $H(Z | X, Y) = 5 - alpha$)
  content((50, 10), $I(X; Y; Z) = 1-alpha$)
})
]]

= Conditionnements croissants

== 
On a l'équation $(1), (2)$ d'après la règle de chainage.

$
& H(X, Y, f(Y)) = H(Y) + H(f(Y) | Y) + H(X | Y, f(Y)) space.quad && (1)\
& H(X, Y, f(Y)) = H(Y) + H(X | Y) + H(f(Y) | X, Y) && (2) \
& "D'où en faisant" (1) - (2) "On obtient "\
& 0 = 0 + H(f(Y) | Y) + H(X | Y, f(Y)) - H(X | Y) - H(f(Y) | X, Y) \
& "Or" H(f(Y) | Y) = H(f(Y)) | X, Y) = 0 && (*)\
& "Donc on a," space #box(stroke : black + 0.5pt, outset : 3pt)[H(X | Y) = H(X | Y, f(Y))]  \
$

$
(*) H(f(Y) | X, Y) & = H(g(X, Y) | X, Y) "avec" g(X, Y) = f(Y) \
& = 0
$

==
$
& I(X; Y, f(Y)) = H(X) - H(X | Y, f(Y)) \
& I(X; Y, f(Y)) = H(X) - H(X | Y) \
& #box(stroke : black + 0.5pt, outset : 3pt)[I(X; Y, f(Y)) = I(X; Y)]\
$

= Théorème du secret parfait

$
"Supposons"
cases(Z = f(X, Y, W), H(X |Y,Z) = 0 , H(X|Z) = H(X)) "Montrons que" H(Y) >= H(X) 
$


$ 

"On a," & H(X,Y,Z) = H(Z) + H(Y|Z) + H(X |Y,Z) && (1) \
"Et on a," & H(X,Y,Z) = H(Z) + H(X|Z) + H(Y | X,Z) && (2) \
"Donc, "& H(X) + H(Y|X,Z) = H(Y|Z) && (1) - (2)

$

D'où on a , $H(X) = H(Y|Z) - H(Y|X,Z) = I(X; Y |Z) <= H(Y) square.small$

= Construction d'un code source

==
Supposons que la source soit uniforme. Alors son entropie vaut $log_2(8) = 3 > 2$.
Comme tous les codes ont une longueur moyenne supérieure à l'entropie, alors on ne peut pas respecter cette contrainte dans tous les cas.

==
Pour réaliser un codage de Shannon, il faut respecter l'inégalité de Kraft car c'est un code préfixe.

Ici, on va coder le message en bits donc sur 2 symboles. Les longueurs $l_i$ sont $(1,4,4,2,5,5,5,5)$. On a :
$ sum 2^(-l_i) &= 1/2 + 2*1/(2^4) + 1/(2^2) + 4*1/(2^5)\
              &= 1 $

On respecte bien l'inégalité de Kraft : $sum 2^(-l_i) <= 1$.

Donc, on peut réaliser un codage de Shannon.

==
On propose le code suivant avec l'arbre associé :

#let data4c = (
  $$, // root
  (
    $$, // 1 
    (
      $$, // 11 
      (
        $$, // 111
        (
          $$,// 1111
          (
            $h$ // 11111
          ), 
          (
            $g$ // 11110
          )
        ), 
        (
          $$, // 1110 
          (
            $f$
          ), 
          (
            $e$
          )
        )
      ), 
      (
        $$, // 110
        (
          $d$ // 1101
        ), 
        (
          $c$ // 1100
        )
      )
    ),
    ($b$) // 10
  ), 
  ($a$) // 0
)

#align(center)[
#stack(
  dir : ltr,
  spacing : 100pt,
  $ cases(a = 0, b = 10, c = 1100, d = 1101, e = 11100, f = 11101, g = 11110, h = 11111) $,
  display_tree_codage(data4c)
)]

==
A la limite de compression de Shannon, on a que la longueur moyenne du code correspond à son entropie. On a la formule suivante pour l'entropie du code X :

$ H(X) =  sum 2^(-l_i) * l_i $
avec $l_i = -log p_i$, solution du problème d'optimisation de la longueur moyenne d'un code

Donc, $EE(L circle.tiny C(X)) = H(X) = 1* 1/2 + 1*2/4 + 2* 4/16 + 4* 5/32 = 2,125 > 2$.


= Codage de Huffman

On pose : 
$PP_X (a) = 4/10$,
$PP_X (b) = 2/10$,
$PP_X (c) = 2/10$,
$PP_X (d) = 1/10$,
$PP_X (e) = 1/10$

==
On propose le code suivant :

#let data5a = (
  $$, // root
  (
    $$, // 1 
    (
      $$, // 11 
      (
        $e$, // 111
      ), 
      (
        $d$, // 110
      )
    ),
    (
      $$, // 10
      (
        $c$
      ),
      (
        $b$
      )
    )
  ), 
  ($a$) // 0
)

#align(center)[
#stack(
  dir : ltr,
  spacing : 50pt,
  $ cases(a = 0, b = 100, c = 101, d = 110, e = 111) $,
  display_tree_codage(data5a)
)]


Sa longueur moyenne vaut : $l_m = 1 * 4/10 + 3 * 6/10 = 2.2$ bits/symboles.


==
On propose le code suivant :

#let data5a = (
  $$, // root
  (
    $$, // 1 
    (
      $$, // 11 
      (
        $$, // 111
        (
          $e$
        ),
        (
          $d$
        )
      ), 
      (
        $c$, // 110
      )
    ),
    (
      $b$, // 10
    )
  ),
  ($a$) // 0
)

#align(center)[
#stack(
  dir : ltr,
  spacing : 50pt,
  $ cases(a = 0, b = 10, c = 110, d = 1110, e = 1111) $,
  display_tree_codage(data5a)
)]

Sa longueur moyenne vaut : $l_m = 1 * 4/10 + 2 * 2/10 + 3 * 2/10 + 4 * 2/ 10  = 2.2 $ bits/symboles.

==
Les deux codes font la même longueur en moyenne. Les deux constructions sont aussi efficaces l'une que l'autre en moyenne pour encoder les messages de cette source.

==

$ H_2(X) &= - sum p_i log_2 p_i\
           &= log_2(5) - 1/5\
           & tilde.eq 2.12 $

  On a bien $H_2(X)<=l_m<H_2(X)+1$. La longueur moyenne est dans le bon intervalle.

= Codage Arithmétique

Le codage arithmétique est une manière de coder de l'information sans perte. L'explication qui suit est principalement a vu pédagogique et vise à faire comprendre le principe de l'algorihtme. Nous allons présenter dans un premier temps l'agorithme de codage et décodage pour ensuite le compararer à d'autres algorithme de codage et enfin présenter une application et un exemple plus complet.

// https://fr.wikipedia.org/wiki/`Codage`_arithm%C3%A9tique
// https://www2.isye.gatech.edu/~yxie77/ece587/Lecture10.pdf
// https://www.cs.cmu.edu/~aarti/Class/10704/Intro_Arith_coding.pdf
// https://www.ece.mcmaster.ca/~shirani/multi10/arithmetic07.pdf

== Définition et Principe :

Le codage arithmétique est un codage entropique utilisé en compression de données sans perte. C'est un codage à longueur variable. Le principe de ce code est de découper le message en morceaux (de taille variable). 


#stack(dir: ltr,
  spacing : 30pt,
  [Par exemple pour ce fichier :],
```c 
aaaaaaaaaa // 10 a
aaaaaaaaaa // 10 a
aaaaa      // 5 a
bbbbbbbbbb // 10 b
bbbbbbbbbb // 10 b
bbbb       // 4 b
```
)






Ce fichier se représente de cette façon où on ajoute un caractère de fin "\$" (EOF) qui n'est pas un caractère de la source. On obtient la distribution de probabilité suivante : $PP(a) = 0.5, PP(b) = 0.48, PP(\$) = 0.02$

#let distrib = (
  ("a", 0.5),
  ("b", 0.48),
  ("$", 0.02)
)

#let message = ""

#align(center, codage_arith(distrib, message))

Ensuite chaque morceau est représenté par nombre flottant. Le message compressé est donc une suite de nombres. 

Comme pour le codage de Huffman, ce code nécessite de connaître tous les symboles dans le message et leur probabilité d'apparition. Dans certaines variantes, les probabilités d'apparition sont calculées à la volée.

Cela permet d'associer à chaque symbole un sous-intervalle de $[0;1[$ de taille proportionnelle à la probabilité d'apparition du symbole. On choisit ensuite un représentant de ce sous-intervalle qui code désormais notre message. Ce représentant peut-être choisit pour optimiser un critère. Par exemple, on choisit le flottant avec la mantisse exprimable avec le moins de bits pour compresser au maximum le message. On peut aussi choisir un représentant pour avoir un code préfixe qui sera plus rapide à décoder.

== Algorithme de codage :

Pour encoder un message, on procède de la manière suivante. On continue avec les mêmes probabilités présenter dans la partie précédente.

On code une lettre après une autre. Si la première lettre est la lettre "a". On fixe le nouvel intervalle $[0;0,5[$.

#align(center, codage_arith(distrib, "a"))

Pour coder ensuite la lettre "b", on change l'intervalle et on obtient l'intervalle $[0,25;0,49]$.

#align(center, codage_arith(distrib, "ab"))

Toute fin de message doit se finir par un "\$". Codons donc le message "ab\$". La visualisation n'affiche que le flottant de gauche de l'intervalle lorsqu'on arrive sur de petits intervalles.

#align(center, codage_arith(distrib, "ab$"))

On obtient donc l'intervalle $[0,4851;0,49[, $. Ici on peut par exemple choisir comme représentant $0.486$ (le nombre flottant le plus proche de ce nombre).

== Algorithme de décodage 

Pour décoder un message, on procède à l'inverse :

#let decodage_value = 0.3383

Prenons par exemple le flottant #decodage_value. Décodons ensemble ce message. Comme $0 < #decodage_value < 0.5$. On sait que le premier caractère du message est "a".

#align(center, codage_arith(distrib, "a", decodage:decodage_value))

On se place donc dans l'intervalle $[0, 0.5]$. Comme notre flottant est #decodage_value on décode un "b".

#align(center, codage_arith(distrib, "ab", decodage:decodage_value))

De même on décode un "a". On a pour l'instant trouver le message "aba". On continue jusqu'à décoder le caractère $\$$ qui termine tout message, sans ce caractère un même flottant peut coder des messages infinis.

#stack(
  spacing : 10pt,
align(center, codage_arith(distrib, "aba",  h:0.03, decodage:decodage_value)),

align(center, codage_arith(distrib, "abab",  h:0.03, decodage:decodage_value)),

align(center, codage_arith(distrib, "ababa",  h:0.03, decodage:decodage_value)),

align(center, codage_arith(distrib, "ababa$", h:0.025, decodage:decodage_value))
)

On obtient donc le message final : "ababa\$".

== Comparaison avec d'autres types de codage :

=== Codage de Huffman

De manière générale, le codage arithmétique est plus efficace que le codage de Huffman, en particulier pour représenter les symboles qui apparaissent très souvent. Dans le codage de Huffman, il faut au moins 1 bit par symbole alors que dans le codage arithmétique, l'intervalle associé au symbole est correspond à sa probabilité. Plus elle est élevée, plus l'intervalle sera grand donc la taille de l'intervalle convergera moins vite vers 0, ce qui mermet d'encoder plus de symboles.

Dans la méthode proposée ici, on a du rajouter un symbole supplémentaire pour signaler la fin du message à décoder, ce qui n'est pas le cas dans le codage de Huffman.

=== Codage de Shannon

Le codage de Huffman étant en moyenne meilleur que ceuil de Shannon, le codage arithmétique est aussi en moyenne meilleur que le code de Shannon. 

== Applications

Le codage arithmétique est peu utilisé en pratique à cause de sa faible résistence au bruit. En effet, à la moindre erreur dans la mantisse du flottant, le message décodé peut être complètement différent du message initial.


Dans l'exemple de décodage ci-dessous, on volait décoder 0.3383 (qui correspond au message 'ababa\$'). Supposons qu'une erreur dans la mantisse nous donne le flottant 0.339. Le message obtenu en décodant 0.339 est ababbaaaaa\$.

#let distrib = (
  ("a", 0.5),
  ("b", 0.48),
  ("$", 0.02)
)

#let message = "ababbaaaaaaaa$"

#align(center, codage_arith(distrib, message, h : 0.03, decodage : 0.339, prec : 10))

#align(center, codage_arith(distrib, "ababa$", h : 0.03, decodage :decodage_value, prec : 6))

/*
#let distrib = (
  ("a", 0.3),
  ("b", 0.48),
  ("c", 0.2),
  ("$", 0.02)
)

#let message = "bbacaa$"

#align(center, codage_arith(distrib, message, h : 0.03, decodage : 0.5, prec : 4, length : 14cm))
*/

#block(stack(
  dir: ltr,
  spacing : 20pt,
  align(center + horizon)[#box(width : 240pt)[
    Le codage arithmétique est utilisé dans la norme compression JPEG2000. En effet on voit que la dernière étape du codage jpeg 2000 prend en entrée des code block. C'est ici qu'est utilisé le codage arithmétique.
  ]],
  figure(
    [],
    caption : [Etape Codage Jpeg 2000 Wikipedia]
  )
))

== Exemple Supplémentaire

Voici un exemple praticuliers qui montre que certains messages peuvent être codés de manière très efficace. Ici 0.5 qui avec un flottant peut être codé en 1 bit représente un message de taille 6 avec 3 caractères possibles.

///////////////////////////////////// SOME TEST

Voici le message :

#dystac()

#input(name: "message", default: "bbacaa", type_input: "text")

#dynamic(
variables : (message : "bacaa"),
```typ

#import "@preview/cetz:0.3.4" : canvas, draw, tree
#let distrib = (
  ("a", 0.3),
  ("b", 0.48),
  ("c", 0.2),
  ("$", 0.02)
)
#let codage_arith(
  distrib,
  message,
  h : 0.06,
  decodage : none,
  length : 18cm,
  prec : 5
)={
canvas(
  length: length,
  {
import draw: *

if message != "" {
  content((h,h * 1.4), [message : #message])
}
content((1 - 0.01, h + h / 5), [EOF])
let draw_interval(posh, begin, end, h)={
  let transform = end - begin
  let offset = begin
  line((begin, posh), (end, posh)) // horizontal axe
  line((begin, posh), (begin, h + posh)) // left vertical line
  for (i, (letter, proba)) in distrib.enumerate() {
    proba *= transform
    offset += proba
    line((offset, posh), (offset, h + posh))
    if end - begin >= 0.04 {
      content((offset - proba / 2, h / 2 + posh), letter)
    }
  }
}

draw_interval(0, 0, 1, h)

let previous_begin = 0
let previous_end = 1

for i in range(message.len()) {
  let letter = message.at(i)

  let end = 0
  let begin = 0
  for (l, proba) in distrib {
    if letter == l {
      end = begin + proba
      break
    }
    begin += proba
  }
  let factor = end - begin
  begin = previous_begin + begin * (previous_end - previous_begin)
  end = previous_begin + end * (previous_end - previous_begin)
  draw_interval(- (i + 1) * h, begin, end, h)
  previous_begin = begin
  previous_end = end
  content(
    (begin - length.pt() / 25000, - h * (i + 1) - h / 8), 
    text(8pt, str(begin).slice(0, calc.min(int(prec),str(begin).len())))
  )
  if end - begin >= 0.03 {
    content(
      (end + length.pt() / 25000, - h * (i + 1) - h / 8), 
      text(8pt, str(end).slice(0, calc.min(int(prec),str(end).len())))
    )
  }
  if i != 0 {
    prec += 1 / i
  }
}
if decodage != none {
  line((decodage, h), (decodage, - message.len() * h), stroke : red + 0.7pt)
  content((decodage, h + h / 2), [#decodage])
}
})
}
#align(center, codage_arith(distrib, message, h : 0.07, decodage : 0.5, prec : 6))
```
)




//// SOME TEST

#let distrib = (
  ("0", 0.5),
  ("1", 0.48),
  ("$", 0.02)
)
#let message = "010000111$"

// #codage_arith_compute(distrib, message)

#let mean_test_binaire(
  distrib,
  message,
  i : 0,
  limit : 4,
  prec : 10
)={
  let (begin, end) = codage_arith_compute(distrib, message + "$")
  let first = str(begin).slice(0, calc.min(int(prec),str(begin).len()))
  let second = str(end).slice(0, calc.min(int(prec),str(end).len())
    )
  let mid = (begin + end) / 2
  let mid_str = str(mid).slice(0, calc.min(str(mid).len(),5))
  $"message" : #message\$ & -> [#begin, #end] & -> "mid" : & #mid_str\ $
  v(2pt)
  if i != limit {
    mean_test_binaire(distrib, message + "0", i : i + 1, limit : limit)
    mean_test_binaire(distrib, message + "1", i : i + 1, limit : limit)
  }
}

// $  #mean_test_binaire(distrib, "") $

#let mean_test_binaire_list(
  distrib,
  message,
  i : 0,
  limit : 3,
  prec : 10,
  result : ()
)={
  let (begin, end) = codage_arith_compute(distrib, message + "$")
  let first = str(begin).slice(0, calc.min(int(prec),str(begin).len()))
  let second = str(end).slice(0, calc.min(int(prec),str(end).len())
    )
  let mid = (begin + end) / 2
  result.push((message + "$", begin, end, mid))
  // $"message" : #message\$ & -> [#begin, #end] & -> "mid" : & #mid_str\ $
  v(2pt)
  if i != limit {
    for value in mean_test_binaire_list(distrib, message + "0", i : i + 1, limit : limit) {
      result.push(value)
    }
    
    for value in mean_test_binaire_list(distrib, message + "1", i : i + 1, limit : limit) {
      result.push(value)
    }
  }
  return result
}

#let test_prec_float(
  limit : 2,
  prec : 4,
)={
// sorted dedup
prec = prec + 2
let result = mean_test_binaire_list(distrib, "", limit : limit, prec : prec)
let result_sorted = result.sorted(key : key => key.at(3))
let result_cut = result_sorted.map(
  key => (key.at(0), key.at(1), key.at(2), 
  float(str(key.at(3)).slice(0, 
    calc.min(str(key.at(3)).len(),prec)
  )))
)
let check_has_double(l)={
  for i in range(l.len() - 1){
    if l.at(i).at(3) == l.at(i+1).at(3) {
      $
      "message" : #l.at(i).at(0),
      "mid" : #l.at(i).at(3)
      \
      "message" : #l.at(i + 1).at(0),
      "mid" : #l.at(i).at(3)
      $
    }
  }
}
// let mid_cut = float(str(mid).slice(0, calc.min(str(mid).len(),prec)))
/*
$
#for value in result_cut {
  let message = value.at(0)
  let begin = value.at(1)
  let end = value.at(2)
  let result = value.at(3)
  $ "message" : #message & -> [begin, end] && -> "result" :  && #result \ $
}
$
*/
check_has_double(result_cut)

}

/*
// prec - 2
#pagebreak()

#let distrib = (
  ("0", 0.5),
  ("1", 0.48),
  ("$", 0.02)
)

#test_prec_float(limit:1, prec:2)
#test_prec_float(limit:2, prec:2)
#test_prec_float(limit:3, prec:3)
#test_prec_float(limit:4, prec:3)
#test_prec_float(limit:5, prec:4)
#test_prec_float(limit:6, prec:4)
#test_prec_float(limit:7, prec:4)
#test_prec_float(limit:8, prec:5)
#test_prec_float(limit:9, prec:5)
#test_prec_float(limit:10, prec:5)
#test_prec_float(limit:11, prec:5)
#test_prec_float(limit:12, prec:6) // 6 chiffres décimal en flottant
#test_prec_float(limit:13, prec:6)
*/

#let mean_test_binaire_list2(
  distrib,
  message,
  i : 0,
  limit : 3,
  prec : 10,
  result : (),
  nb0 : 0,
  nb1 : 0,
)={
  if 8 * nb0 == nb1 or 8 * nb0 + 1 == nb1 or 8 * nb0 - 1 == nb1 {
    let (begin, end) = codage_arith_compute(distrib, message + "$")
    let first = str(begin).slice(0, calc.min(int(prec),str(begin).len()))
    let second = str(end).slice(0, calc.min(int(prec),str(end).len())
    )
    let mid = (begin + end) / 2
  
    result.push((message + "$", begin, end, mid))
  }
  // $"message" : #message\$ & -> [#begin, #end] & -> "mid" : & #mid_str\ $
  v(2pt)
  if i != limit {
    for value in mean_test_binaire_list2(distrib, message + "0", i : i + 1, limit : limit, nb0 : nb0 + 1, nb1 : nb1) {
      result.push(value)
    }
    
    for value in mean_test_binaire_list2(distrib, message + "1", i : i + 1, limit : limit, nb0 : nb0, nb1 : nb1 + 1) {
      result.push(value)
    }
  }
  return result
}

#let test_prec_float2(
  limit : 2,
  prec : 4,
)={
prec = prec + 2
let distrib = (
  ("0", 0.10),
  ("1", 0.89),
  ("$", 0.01)
)
// sorted dedup
let result = mean_test_binaire_list2(distrib, "", limit : limit, prec : prec)
let result_sorted = result.sorted(key : key => key.at(3))
let result_cut = result_sorted.map(
  key => (key.at(0), key.at(1), key.at(2), 
  float(str(key.at(3)).slice(0, 
    calc.min(str(key.at(3)).len(),prec)
  )))
)
let check_has_double(l)={
  for i in range(l.len() - 1){
    if l.at(i).at(3) == l.at(i+1).at(3) {
      $
      "message" : #l.at(i).at(0),
      "mid" : #l.at(i).at(3)
      \
      "message" : #l.at(i + 1).at(0),
      "mid" : #l.at(i).at(3)
      $
    }
  }
}

// let mid_cut = float(str(mid).slice(0, calc.min(str(mid).len(),prec)))
/*
$
#for value in result_cut {
  let message = value.at(0)
  let begin = value.at(1)
  let end = value.at(2)
  let result = value.at(3)
  $ "message" : #message & -> [begin, end] && -> "result" :  && #result \ $
}
$
*/
check_has_double(result_cut)
}

/*

#let distrib = (
  ("0", 0.5),
  ("1", 0.48),
  ("$", 0.02)
)

#test_prec_float2(limit:2, prec:1)
#test_prec_float2(limit:3, prec:1)
#test_prec_float2(limit:4, prec:2)
#test_prec_float2(limit:5, prec:2)

#test_prec_float2(limit:6, prec:2)
#test_prec_float2(limit:7, prec:2)
#test_prec_float2(limit:8, prec:3)
#test_prec_float2(limit:9, prec:3)
#test_prec_float2(limit:10, prec:4)
#test_prec_float2(limit:11, prec:4)
#test_prec_float2(limit:12, prec:4)
#test_prec_float2(limit:13, prec:4)
#test_prec_float2(limit:14, prec:5)
#test_prec_float2(limit:15, prec:5)
#test_prec_float2(limit:16, prec:5)
#test_prec_float2(limit:17, prec:5)
#test_prec_float2(limit:18, prec:6)
*/

/*
let distrib = (
  ("0", 0.25),
  ("1", 0.73),
  ("$", 0.02)
)
#test_prec_float2(limit:2, prec:2)
#test_prec_float2(limit:3, prec:2)
#test_prec_float2(limit:4, prec:3)
#test_prec_float2(limit:5, prec:3)
#test_prec_float2(limit:6, prec:3)
#test_prec_float2(limit:7, prec:4)
#test_prec_float2(limit:8, prec:4)
#test_prec_float2(limit:9, prec:4)
#test_prec_float2(limit:10, prec:5)
#test_prec_float2(limit:11, prec:5)
#test_prec_float2(limit:12, prec:5)
#test_prec_float2(limit:13, prec:6)
#test_prec_float2(limit:14, prec:6)
#test_prec_float2(limit:15, prec:6)
#test_prec_float2(limit:16, prec:7)
#test_prec_float2(limit:17, prec:7)
#test_prec_float2(limit:18, prec:7)
*/
// #test_prec_float2(limit:19, prec:7)

/*
let distrib = (
  ("0", 0.10),
  ("1", 0.89),
  ("$", 0.01)
)
*/
/*

#test_prec_float2(limit:9, prec:4)
#test_prec_float2(limit:10, prec:4)
#test_prec_float2(limit:11, prec:4)
#test_prec_float2(limit:12, prec:4)
#test_prec_float2(limit:13, prec:4)
#test_prec_float2(limit:14, prec:4)
#test_prec_float2(limit:15, prec:4)
#test_prec_float2(limit:16, prec:4)
#test_prec_float2(limit:17, prec:4)
#test_prec_float2(limit:18, prec:5)
#test_prec_float2(limit:19, prec:5)
*/
/*
#test_prec_float2(limit:10, prec:4)
#test_prec_float2(limit:11, prec:4)
#test_prec_float2(limit:12, prec:4)
#test_prec_float2(limit:13, prec:4)
#test_prec_float2(limit:14, prec:4)
#test_prec_float2(limit:15, prec:4)
#test_prec_float2(limit:16, prec:4)
#test_prec_float2(limit:17, prec:4)
#test_prec_float2(limit:18, prec:4)
*/

// #test_prec_float2(limit:19, prec:4)
