import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.14 — Lambda Abstraction (Expr.lam)" =>

%%%
tag := "m1-14"
file := "1-14"
number := false
%%%

:::callout (kind := "goals")
* Να γνωρίσεις την κατασκευή `Expr.lam`, την ίδια τη συνάρτηση.
* Να ξεχωρίζεις `lam` (συνάρτηση) από `forallE` (τύπος της).
* Να μαντεύεις τον τύπο μιας `lam` από τους μηχανισμούς που ήδη ξέρεις.
:::

# Το κομμάτι που έλειπε

%%%
tag := "1-14-missing"
%%%

:::table +header
*
  * Κατασκευή
  * Ρόλος
*
  * `Expr.forallE`
  * ο *τύπος* μιας συνάρτησης
*
  * `Expr.app`
  * η *εφαρμογή* μιας συνάρτησης
*
  * `Expr.lam`
  * η *ίδια η συνάρτηση* (νέο!)
:::

```lean (name := lamSig)
#check @Lean.Expr.lam
```
```leanOutput lamSig
Lean.Expr.lam : Lean.Name → Lean.Expr → Lean.Expr → Lean.BinderInfo → Lean.Expr
```

Ακριβώς η ίδια υπογραφή με το `forallE`! Η διαφορά είναι στη *σημασία* του `body`:

:::table +header
*
  * Πεδίο
  * `forallE`
  * `lam`
*
  * `binderName`
  * όνομα ορίσματος
  * όνομα ορίσματος
*
  * `binderType`
  * τύπος ορίσματος
  * τύπος ορίσματος
*
  * `body`
  * *τύπος* του αποτελέσματος
  * *term* του αποτελέσματος
:::

# Η απλούστερη συνάρτηση

%%%
tag := "1-14-identity"
%%%

Η ταυτοτική στους φυσικούς, $`f(x) = x`, γράφεται στη Lean `fun (x : Nat) => x`. Εσωτερικά:

```lean
open Lean in
def identityExpr : Expr := .lam `x (.const `Nat []) (.bvar 0) .default
```

Η λέξη `fun` είναι η σύνταξη της Lean για το λ του _λογισμού λ_ (λ-calculus).

:::figure (src := "e01/lam-vs-forall.svg") (caption := "Η συνάρτηση και ο τύπος της, δίπλα δίπλα. Ίδιο σχήμα, διαφορετικό body: στη lam το body είναι μια τιμή (bvar 0 = το x), ενώ στο forallE είναι ένας τύπος (Nat).")
:::

```lean (name := idCheck)
#check fun (x : Nat) => x
```
```leanOutput idCheck
fun x => x : Nat → Nat
```

$$`\vdash (\lambda\, x : \mathsf{Nat}.\ x) : (\Pi\, x : \mathsf{Nat},\ \mathsf{Nat})`

Η `lam` *κατασκευάζει* τη συνάρτηση. Το `forallE` *περιγράφει* τον τύπο της.

# Ερώτηση κατανόησης

%%%
tag := "1-14-askisi"
%%%

::::callout (kind := "exercise")
Για τη σταθερή συνάρτηση `fun (x : Nat) => true`, δηλαδή `lam(x, Nat, Bool.true)`:

1. Σε ποιο context ελέγχει ο kernel το body;
2. Ποιος είναι ο τύπος του body;
3. Ποιο `forallE` είναι ο τύπος όλης της συνάρτησης;

(Δεν έχουμε δει ακόμη τον κανόνα. Προσπάθησε να τον μαντέψεις.)

:::solution

1. $`\Gamma = (x : \mathsf{Nat})`. Το `x` μπαίνει στο context *ακόμη κι αν δεν χρησιμοποιείται*.
2. `Bool`.
3. `forallE(x, Nat, Bool)`, δηλαδή `Nat → Bool`.

```lean (name := constFn)
#check fun (x : Nat) => true
```
```leanOutput constFn
fun x => true : Nat → Bool
```

Αυτό είναι ακριβώς ο κανόνας του επόμενου μαθήματος.
:::
::::

:::callout (kind := "summary")
* `Expr.lam name type body info` είναι η ίδια η συνάρτηση. Στη Lean γράφεται `fun (x : A) => body`.
* Ίδια υπογραφή με το `forallE`, αλλά το body είναι *term*, όχι τύπος.
* Το body ελέγχεται σε context που περιέχει το όρισμα.
:::
