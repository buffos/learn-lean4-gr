import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.6 — Global Environment και Constant Rule" =>

%%%
tag := "m1-6"
file := "1-6"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τι είναι το global environment $`\Sigma`.
* Να εφαρμόζεις τον _Constant Rule_.
* Να ξεχωρίζεις ποιον από τους τρεις κανόνες (Sort, Var, Const) εφαρμόζει ο kernel σε κάθε term.
* Να βλέπεις τη δομή του αλγορίθμου `inferType`.
:::

# Από πού ξέρει ο kernel τον τύπο του Nat;

%%%
tag := "1-6-question"
%%%

Ως τώρα έχουμε δύο κανόνες: τον *Sort*, που είναι εγγενής, και τον *Var*, που παίρνει
τον τύπο από το context. Ο `Nat` όμως δεν είναι ούτε Sort ούτε τοπική μεταβλητή. Τότε
από πού ξέρει ο kernel ότι $`\mathsf{Nat} : \mathsf{Sort}\ 1`, με κενό context;

Η απάντηση είναι το *global environment* $`\Sigma`: όλες οι καθολικές δηλώσεις που έχουν
εισαχθεί στη Lean (από τη βασική βιβλιοθήκη, από imports, από τα `def` μας).

```lean (name := envNames)
#check Nat
#check Nat.zero
#check Bool.false
```
```leanOutput envNames
Nat : Type
```

Ο kernel δεν έχει ειδικό κανόνα για καθεμία από αυτές τις σταθερές. Απλώς *ψάχνει
τη δήλωσή τους* στο environment.

# Η πλήρης μορφή του judgment

%%%
tag := "1-6-full"
%%%

$$`\Sigma\,;\ \Gamma \vdash t : T`

Ως τώρα παραλείπαμε το $`\Sigma`, θεωρώντας το δεδομένο.

:::figure (src := "e01/sigma-gamma.svg") (caption := "Δύο πηγές πληροφορίας: το μόνιμο environment Σ και το προσωρινό τοπικό context Γ.")
:::

# Η εσωτερική αναπαράσταση: Expr.const

%%%
tag := "1-6-const"
%%%

```lean (name := constSig)
#check @Lean.Expr.const
```
```leanOutput constSig
Lean.Expr.const : Lean.Name → List Lean.Level → Lean.Expr
```

Δέχεται το *όνομα* της σταθεράς και μια λίστα *universe levels* (για τον `Nat` η λίστα
είναι κενή). Μπορούμε να φτιάξουμε την έκφραση και μόνοι μας:

```lean
open Lean in
def natExpr : Expr := .const `Nat []

open Lean in
def sort1Expr : Expr := .sort (.succ .zero)
```

:::callout (kind := "note") (title := "Το Expr.const δεν αποθηκεύει τύπο")
Η έκφραση κρατάει μόνο το _όνομα_ `Nat`. Ο τύπος του δεν είναι γραμμένος μέσα της.
Κάθε φορά που χρειάζεται, ο kernel τον αναζητά στο environment.
:::

# Ο Constant Rule

%%%
tag := "1-6-rule"
%%%

Για σταθερές χωρίς universe parameters (τη γενική μορφή θα τη δούμε στο 1.26):

$$`\dfrac{(c : T) \in \Sigma}{\Sigma\,;\ \Gamma \vdash c : T}\ \textsf{(Const)}`

:::table +header
*
  * Κανόνας
  * Κατασκευή
  * Από πού έρχεται ο τύπος
*
  * Sort
  * `Expr.sort`
  * εγγενής γνώση του kernel
*
  * Var
  * τοπική μεταβλητή
  * τοπικό context $`\Gamma`
*
  * Const
  * `Expr.const`
  * environment $`\Sigma`
:::

# Ερωτήσεις κατανόησης

%%%
tag := "1-6-askiseis"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Ποιος κανόνας;")
Με $`\Gamma = (A : \mathsf{Sort}\ 1,\ x : A)`, ποιον κανόνα χρησιμοποιεί ο kernel για καθένα από τα παρακάτω;

1. $`\mathsf{Nat} : \mathsf{Sort}\ 1`
2. $`A : \mathsf{Sort}\ 1`
3. $`\mathsf{Sort}\ 1 : \mathsf{Sort}\ 2`
4. $`x : A`

Και αν αδειάσουμε το $`\Gamma`, ποια από αυτά μένουν έγκυρα;

::::solution
:::table +header
*
  * Judgment
  * Κανόνας
  * Πηγή
*
  * $`\mathsf{Nat} : \mathsf{Sort}\ 1`
  * Const
  * $`\Sigma`
*
  * $`A : \mathsf{Sort}\ 1`
  * Var
  * $`\Gamma`
*
  * $`\mathsf{Sort}\ 1 : \mathsf{Sort}\ 2`
  * *Sort*
  * εγγενής
*
  * $`x : A`
  * Var
  * $`\Gamma`
:::

Με κενό $`\Gamma` μένουν τα *1 και 3*.

Συχνό λάθος: να θεωρηθεί το 3 constant. Το `Sort 1` όμως δεν είναι όνομα
δηλωμένο στο environment, αλλά πρωτογενής κατασκευή (`Expr.sort`). Ο τύπος του
υπολογίζεται απευθείας από το level, χωρίς αναζήτηση.
::::
:::::

# Ο αλγόριθμος ως τώρα

%%%
tag := "1-6-algorithm"
%%%

Αρχίζει να φαίνεται η δομή του type checker. Σε απλοποιημένο ψευδοκώδικα:

```
inferType(e, Σ, Γ):
  match e:
    sort(u)        → sort(succ(u))           -- Sort rule
    const(c, ls)   → Σ.lookupType(c, ls)     -- Const rule
    fvar(x)        → Γ.lookupType(x)         -- Var rule
    lit(natVal n)  → const(Nat, [])          -- Literal rule (1.7)
```

:::callout (kind := "deep") (title := "Ο πραγματικός kernel")
Ο kernel της Lean είναι γραμμένος σε C++ (`src/kernel/type_checker.cpp`), και η συνάρτηση
`infer_type_core` έχει ακριβώς αυτή τη μορφή: ένα `switch` πάνω στο είδος του `Expr`.
Σε κάθε μάθημα θα προσθέτουμε μία γραμμή σε αυτό το `match`.
:::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Τι ξέρει ο kernel «από γεννησιμιού του»;")
Με *εντελώς κενό* environment και context, ποια από τα παρακάτω μπορεί ακόμη να τεκμηριώσει ο kernel;

1. $`\mathsf{Nat} : \mathsf{Sort}\ 1`
2. $`\mathsf{Sort}\ 0 : \mathsf{Sort}\ 1`
3. $`\mathsf{Bool} : \mathsf{Sort}\ 1`
4. $`\mathsf{Sort}\ 1 : \mathsf{Sort}\ 2`
5. $`\mathsf{Sort}\ 100 : \mathsf{Sort}\ 101`

:::solution
*Τα 2, 4, 5*, όλα με τον κανόνα Sort, που είναι εγγενής.
Τα `Nat` και `Bool` χρειάζονται δηλώσεις στο environment.
:::
::::

:::callout (kind := "summary")
* Το judgment στην πλήρη μορφή του: $`\Sigma\,;\ \Gamma \vdash t : T`.
* *Const Rule:* αν $`(c : T) \in \Sigma`, τότε $`\Sigma ; \Gamma \vdash c : T`.
* Το `Expr.const` κρατάει μόνο όνομα και levels. Ο τύπος αναζητείται.
* Ο kernel είναι ένα `match` πάνω στην κατασκευή του `Expr`.
:::
