import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.18 — Let Expressions (Expr.letE)" =>

%%%
tag := "m1-18"
file := "1-18"
number := false
%%%

:::callout (kind := "goals")
* Να γνωρίσεις την κατασκευή `Expr.letE`.
* Να ξεχωρίζεις τις δύο μορφές τοπικής δήλωσης: $`x : A` και $`x : A := a`.
* Να καταλάβεις τι σημαίνει για τον kernel «ξέρω την τιμή μιας μεταβλητής».
:::

# Τοπική μεταβλητή με τιμή

%%%
tag := "1-18-idea"
%%%

Ως τώρα, ό,τι έμπαινε στο context είχε τύπο αλλά όχι τιμή: $`\Gamma = (x : \mathsf{Nat})`.
Υπάρχει όμως και η δυνατότητα να εισαγάγουμε μια τοπική μεταβλητή *με καθορισμένη τιμή*.

```lean (name := letESig)
#check @Lean.Expr.letE
```
```leanOutput letESig
Lean.Expr.letE : Lean.Name → Lean.Expr → Lean.Expr → Lean.Expr → Bool → Lean.Expr
```

:::table +header
*
  * Πεδίο
  * Σημασία
*
  * `declName`
  * όνομα της μεταβλητής
*
  * `type`
  * τύπος της
*
  * `value`
  * *τιμή* της (νέο!)
*
  * `body`
  * η έκφραση όπου χρησιμοποιείται
*
  * `nonDep`
  * βοηθητική πληροφορία (την αγνοούμε)
:::

# Παράδειγμα

%%%
tag := "1-18-example"
%%%

```lean (name := letEx)
#check let x : Nat := 5; Nat.succ x
```
```leanOutput letEx
let x := 5;
x.succ : Nat
```

Εσωτερικά:

```
letE (x)
├── const Nat          -- type
├── lit 5              -- value
└── app                -- body
    ├── const Nat.succ
    └── bvar 0
```

Όπως τα `lam` και `forallE`, το `letE` εισάγει binder, μόνο που αυτή τη φορά ο binder
συνοδεύεται από τιμή.

# Δύο μορφές τοπικής δήλωσης

%%%
tag := "1-18-two-forms"
%%%

Μέσα στο body, το context είναι $`\Gamma' = (x : \mathsf{Nat} := 5)`. Ο kernel ξέρει *δύο*
πράγματα: τον τύπο (`Nat`) και τον ορισμό (`5`). Το δεύτερο θα το χρησιμοποιήσει στο _reduction_.

:::table +header
*
  * Κατασκευή
  * Επέκταση του context
*
  * `forallE(x, A, B)`
  * $`x : A`
*
  * `lam(x, A, t)`
  * $`x : A`
*
  * `letE(x, A, a, t)`
  * $`x : A := a`
*
  * `app(f, a)`
  * καμία
:::

# Ερώτηση κατανόησης

%%%
tag := "1-18-askisi"
%%%

::::callout (kind := "exercise")
```lean
def ex := fun (x : Nat) =>
  let y : Nat := Nat.succ x
  y
```
Όταν ο kernel φτάσει στο τελευταίο `y`, ποιο είναι το context; Ξέρει την τιμή του `y`,
παρόλο που δεν ξέρει την τιμή του `x`;

:::solution
*Ναι.* Η τιμή του `y` είναι η έκφραση `app(Nat.succ, x)`.

$$`\Gamma = (x : \mathsf{Nat},\ \ y : \mathsf{Nat} := \mathsf{Nat.succ}\ x)`

Για τον kernel, «ξέρω την τιμή» σημαίνει *ξέρω την έκφραση που την ορίζει*, και όχι κάποιον
συγκεκριμένο αριθμό. Η έκφραση `Nat.succ x` μπορεί να περιέχει άλλες μεταβλητές χωρίς τιμή.
:::
::::

:::callout (kind := "summary")
* `Expr.letE name type value body` είναι η κατασκευή. Στη Lean γράφεται `let x : A := a; body`.
* Επεκτείνει το context με $`x : A := a`, δηλαδή με τύπο *και* ορισμό.
* «Τιμή» για τον kernel σημαίνει μια έκφραση, όχι απαραίτητα έναν συγκεκριμένο αριθμό.
:::
