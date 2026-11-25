import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.22 — Index Shifting" =>

%%%
tag := "m1-22"
file := "1-22"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί, όταν μεταφέρουμε ένα term κάτω από νέους binders, οι δείκτες του πρέπει να αλλάξουν.
* Να ξέρεις την πράξη $`\mathrm{shift}(k, c, \cdot)` με το _cutoff_ $`c`.
* Να ξεχωρίζεις ποιοι δείκτες μετατοπίζονται και ποιοι όχι.
:::

# Αλλαγή πλαισίου αναφοράς

%%%
tag := "1-22-frame"
%%%

Μέσα στο scope του `y`, το `bvar 0` σημαίνει `y`. Αν μεταφέρουμε αυτή την αναφορά κάτω από
έναν *νέο* binder `z`, το `bvar 0` θα σημαίνει πλέον `z`. Για να συνεχίσει να δείχνει στο `y`,
πρέπει να γίνει `bvar 1`:

```
lam (y)               lam (y)                 lam (y)
├── Nat               ├── Nat                 ├── Nat
└── bvar 0  -- y      └── lam (z)             └── lam (z)
                          ├── Nat                 ├── Nat
                          └── bvar 0  -- z ✗      └── bvar 1  -- y ✓
```

Αυτό λέγεται *index shifting* (μετατόπιση δεικτών).

# Δεν μετατοπίζονται όλοι οι δείκτες

%%%
tag := "1-22-not-all"
%%%

Αν το term που μεταφέρουμε έχει *δικούς του* binders, οι αναφορές σε αυτούς δεν πρέπει να αλλάξουν:

:::table +header
*
  * Αναφορά
  * Πριν
  * Μετά (1 νέος εξωτερικός binder)
*
  * στον δικό του binder `x`
  * `bvar 0`
  * `bvar 0`
*
  * στον εξωτερικό binder `y`
  * `bvar 1`
  * `bvar 2`
:::

Άρα δεν αρκεί να προσθέσουμε 1 σε όλους τους δείκτες.

# Το cutoff

%%%
tag := "1-22-cutoff"
%%%

$$`\mathrm{shift}(k, c, \mathsf{bvar}\ i) = \begin{cases} \mathsf{bvar}\ (i + k) & i \ge c \\ \mathsf{bvar}\ i & i < c \end{cases}`

:::table +header
*
  * Παράμετρος
  * Σημασία
*
  * $`k`
  * *πόσο* μετατοπίζουμε
*
  * $`c`
  * *από ποιο δείκτη και πάνω* μετατοπίζουμε (cutoff)
:::

```
shift(k, c, bvar i)     = if i ≥ c then bvar (i+k) else bvar i
shift(k, c, app f a)    = app (shift(k, c, f)) (shift(k, c, a))
shift(k, c, lam x A t)  = lam x (shift(k, c, A)) (shift(k, c+1, t))
```

Κάθε φορά που μπαίνουμε στο body ενός binder, το cutoff ανεβαίνει κατά 1. Έτσι
προστατεύονται οι μεταβλητές που δεσμεύονται *μέσα* στο ίδιο το term.

:::figure (src := "e01/shift-cutoff.svg") (caption := "Μετατόπιση κατά k = 2 με αρχικό cutoff 0. Μέσα στη lam το cutoff γίνεται 1: το bvar 0 (το x) μένει, ενώ το bvar 1 (εξωτερικό) γίνεται bvar 3.")
:::

Στη Lean, αυτή η πράξη λέγεται `Expr.liftLooseBVars`:

```lean (name := lift)
open Lean in
#eval (Expr.lam `x (.const `Nat []) (.app (.bvar 1) (.bvar 0)) .default).liftLooseBVars 0 2
```
```leanOutput lift
Lean.Expr.lam
  `x
  (Lean.Expr.const `Nat [])
  (Lean.Expr.app (Lean.Expr.bvar 3) (Lean.Expr.bvar 0))
  (Lean.BinderInfo.default)
```

# Ερώτηση κατανόησης

%%%
tag := "1-22-askisi"
%%%

:::::callout (kind := "exercise")
Στον κανόνα της `lam`, γιατί αυξάνουμε το cutoff στο body `t`, αλλά όχι στο domain `A`;

::::solution
Επειδή ο binder `x` ισχύει *μόνο στο body*. Στο domain `A` δεν έχει μπει ακόμη στο context
(όπως είδαμε στους κανόνες Pi και Lam), άρα εκεί δεν υπάρχει νέα εσωτερική μεταβλητή να προστατέψουμε.

:::callout (kind := "mistake") (title := "Το cutoff δεν είναι το ποσό της μετατόπισης")
Εύκολα μπερδεύει κανείς τα δύο. Το *$`k`* λέει _πόσο_ μετατοπίζονται οι δείκτες, και μένει
σταθερό σε όλη την αναδρομή. Το *$`c`* λέει _ποιοι_ μετατοπίζονται, και ανεβαίνει κάθε φορά που
μπαίνουμε σε binder.
:::
::::
:::::

:::callout (kind := "summary")
* Όταν ένα term μπαίνει κάτω από $`k` νέους binders, οι *εξωτερικές* του αναφορές πρέπει να αυξηθούν κατά $`k`.
* Οι αναφορές σε binders *μέσα* στο term δεν αλλάζουν. Αυτό το εξασφαλίζει το cutoff $`c`.
* $`\mathrm{shift}(k,c,\mathsf{bvar}\ i) = \mathsf{bvar}(i+k)` αν $`i \ge c`. Μέσα σε binder, $`c \mapsto c+1`.
* Στη Lean: `Expr.liftLooseBVars`.
:::
