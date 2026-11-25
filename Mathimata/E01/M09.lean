import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.9 — Η εσωτερική αναπαράσταση των Function Types" =>

%%%
tag := "m1-9"
file := "1-9"
number := false
%%%

:::callout (kind := "goals")
* Να γνωρίσεις την κατασκευή `Expr.forallE` και τα τέσσερα πεδία της.
* Να ξεχωρίζεις τον *τύπο* μιας συνάρτησης (`forallE`) από την *εφαρμογή* της (`app`).
* Να σχεδιάζεις το δέντρο ενός τύπου συνάρτησης.
:::

# Η κατασκευή Expr.forallE

%%%
tag := "1-9-forallE"
%%%

Θα περίμενε κανείς μια κατασκευή `Expr.functionType A B`. *Δεν υπάρχει.* Υπάρχει κάτι
γενικότερο:

```lean (name := forallSig)
#check @Lean.Expr.forallE
```
```leanOutput forallSig
Lean.Expr.forallE : Lean.Name → Lean.Expr → Lean.Expr → Lean.BinderInfo → Lean.Expr
```

:::table +header
*
  * Πεδίο
  * Ρόλος
  * Για το `Nat → Bool`
*
  * `binderName`
  * όνομα του ορίσματος
  * π.χ. `x` (δεν χρησιμοποιείται)
*
  * `binderType`
  * τύπος του ορίσματος (_domain_)
  * `Nat`
*
  * `body`
  * τύπος του αποτελέσματος (_codomain_)
  * `Bool`
*
  * `binderInfo`
  * πώς δηλώνεται το όρισμα (ρητό, `{}`, `[]`)
  * `.default`
:::

```lean
open Lean in
def natToBool : Expr :=
  .forallE `x (.const `Nat []) (.const `Bool []) .default
```

:::callout (kind := "note") (title := "Γιατί υπάρχει όνομα ορίσματος;")
Στο `Nat → Bool` το όνομα `x` δεν χρησιμοποιείται πουθενά. Το `forallE` όμως είναι
φτιαγμένο για τη γενική περίπτωση, όπου ο τύπος του αποτελέσματος *εξαρτάται* από το
όρισμα. Εκεί το όνομα χρειάζεται. Αυτό είναι το θέμα του μαθήματος 1.11, και εξηγεί και το
όνομα «forall».
:::

# Τύπος συνάρτησης ή εφαρμογή συνάρτησης;

%%%
tag := "1-9-vs-app"
%%%

:::table +header
*
  * Κατασκευή
  * Παράδειγμα
  * Τι αναπαριστά
*
  * `Expr.forallE`
  * `Nat → Nat`
  * τον *τύπο* μιας συνάρτησης
*
  * `Expr.app`
  * `Nat.succ 5`
  * την *εφαρμογή* μιας συνάρτησης
:::

Στο judgment $`\vdash \mathsf{Nat.succ} : \mathsf{Nat} \to \mathsf{Nat}`, η αριστερή πλευρά
είναι `Expr.const` και η δεξιά `Expr.forallE`. Και οι δύο είναι αντικείμενα `Lean.Expr`.

# Η δομή του δέντρου καθορίζει τη σημασία

%%%
tag := "1-9-trees"
%%%

Κάθε `→` γίνεται ένα `forallE`. Αν γράψουμε συντομογραφικά `forallE(domain, codomain)`:

:::::callout (kind := "exercise")
Πώς γράφονται οι `Nat → Bool → Nat` και `(Nat → Bool) → Nat` με αυτή τη σημειογραφία;

::::solution

```
Nat → Bool → Nat     =  forallE(Nat, forallE(Bool, Nat))
(Nat → Bool) → Nat   =  forallE(forallE(Nat, Bool), Nat)
```

Οι ίδιες κατασκευές, σε διαφορετική διάταξη:

:::figure (src := "e01/forall-trees.svg") (caption := "Το εμφωλευμένο forallE μπαίνει δεξιά (codomain) ή αριστερά (domain), και αυτό αλλάζει τη σημασία.")
:::
::::
:::::

:::callout (kind := "summary")
* Ο kernel δεν έχει «τύπο συνάρτησης». Έχει το γενικότερο `Expr.forallE name domain body info`.
* Το `forallE` αναπαριστά *τύπο*, ενώ το `app` *εφαρμογή*.
* Το `A → B → C` είναι `forallE(A, forallE(B, C))`, και η θέση του εμφωλευμένου κόμβου καθορίζει τη σημασία.
:::
