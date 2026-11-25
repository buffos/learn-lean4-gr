import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.12 — Bound Variables και De Bruijn Indices" =>

%%%
tag := "m1-12"
file := "1-12"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί ο kernel δεν χρησιμοποιεί ονόματα για τις δεσμευμένες μεταβλητές.
* Να γνωρίσεις την κατασκευή `Expr.bvar` και τους _De Bruijn indices_.
* Να υπολογίζεις τον δείκτη μιας μεταβλητής ανάλογα με τη θέση της.
:::

# Το πρόβλημα των ονομάτων

%%%
tag := "1-12-names"
%%%

Οι τύποι `(A : Sort 1) → A` και `(B : Sort 1) → B` είναι μαθηματικά *ο ίδιος τύπος*:
απλώς αλλάξαμε το όνομα της δεσμευμένης μεταβλητής. Η μετονομασία λέγεται _α-renaming_, και
δύο εκφράσεις που διαφέρουν μόνο σε αυτό λέγονται _α-ισοδύναμες_.

```lean (name := alphaEq)
example : ((A : Type) → A) = ((B : Type) → B) := rfl
```

Αν ο kernel κρατούσε ονόματα, θα έπρεπε σε κάθε σύγκριση να «ταιριάζει» ονόματα. Αντί γι'
αυτό, χρησιμοποιεί *De Bruijn indices* (από τον Ολλανδό μαθηματικό N. G. de Bruijn).

# Η κατασκευή Expr.bvar

%%%
tag := "1-12-bvar"
%%%

```lean (name := bvarSig)
#check @Lean.Expr.bvar
```
```leanOutput bvarSig
Lean.Expr.bvar : Nat → Lean.Expr
```

Αντί για όνομα, μια δεσμευμένη μεταβλητή είναι ένας *αριθμός*: πόσους binders πρέπει να
περάσουμε προς τα έξω για να βρούμε αυτόν που τη δεσμεύει.

:::table +header
*
  * Έκφραση
  * Αναφέρεται στον…
*
  * `bvar 0`
  * πλησιέστερο binder
*
  * `bvar 1`
  * δεύτερο πλησιέστερο binder
*
  * `bvar 2`
  * τρίτο πλησιέστερο binder
:::

Η αρίθμηση ξεκινά από το 0 και μετράει *από μέσα προς τα έξω*.

# Πρώτο παράδειγμα

%%%
tag := "1-12-example"
%%%

Το `(A : Sort 1) → A` είναι `forallE(A, Sort 1, bvar 0)`:

```lean
open Lean in
def piA : Expr := .forallE `A (.sort (.succ .zero)) (.bvar 0) .default
```

Το όνομα `A` εξακολουθεί να αποθηκεύεται στον binder (για να το τυπώνει η Lean όμορφα),
αλλά *δεν* χρησιμοποιείται για να βρεθεί σε τι αναφέρεται το `bvar 0`.

:::callout (kind := "tip") (title := "Τώρα η α-ισοδυναμία είναι δωρεάν")
Και το `(A : Sort 1) → A` και το `(B : Sort 1) → B` γίνονται `forallE(_, Sort 1, bvar 0)`.
Για τον kernel είναι *η ίδια ακριβώς δομή δεδομένων*. Η σύγκριση γίνεται απλή ισότητα δέντρων.
:::

# Ο δείκτης εξαρτάται από τη θέση

%%%
tag := "1-12-position"
%%%

:::::callout (kind := "exercise")
Στο `(A : Sort 1) → (x : A) → A`, και οι δύο εμφανίσεις του `A` πρέπει να γίνουν `bvar`.
Ποιος είναι ο δείκτης σε κάθε θέση;

```
forallE (A)
├── Sort 1
└── forallE (x)
    ├── bvar ?     -- A
    └── bvar ?     -- A
```

::::solution
*`bvar 0` στο πρώτο, `bvar 1` στο δεύτερο.*

:::figure (src := "e01/debruijn.svg") (caption := "Στο domain του εσωτερικού forallE ο binder x δεν ισχύει ακόμη, ενώ στο codomain ισχύει και «σπρώχνει» το A μία θέση πιο μακριά.")
:::

Η ίδια μεταβλητή `A` έχει διαφορετικό δείκτη σε διαφορετικές θέσεις, γιατί η απόστασή
της από τον πλησιέστερο binder είναι διαφορετική.
::::
:::::

:::callout (kind := "summary")
* Ο kernel αναπαριστά τις δεσμευμένες μεταβλητές με `Expr.bvar n`, όχι με ονόματα.
* Το `n` μετράει binders από μέσα προς τα έξω, ξεκινώντας από 0.
* Οι α-ισοδύναμες εκφράσεις γίνονται *ίδια* δέντρα.
* Ο δείκτης της ίδιας μεταβλητής αλλάζει ανάλογα με το πόσοι binders μεσολαβούν.
:::
