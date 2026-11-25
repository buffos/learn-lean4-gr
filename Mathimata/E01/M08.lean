import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.8 — Function Types" =>

%%%
tag := "m1-8"
file := "1-8"
number := false
%%%

:::callout (kind := "goals")
* Να διαβάζεις τύπους συναρτήσεων `A → B → C` σωστά (το `→` δένει από δεξιά).
* Να καταλάβεις το _currying_: κάθε συνάρτηση παίρνει ένα όρισμα.
* Να βρίσκεις τον τύπο μιας μερικής εφαρμογής.
* Να ξέρεις ότι και ο τύπος μιας συνάρτησης είναι term.
:::

# Κάθε συνάρτηση παίρνει ένα όρισμα

%%%
tag := "1-8-one-arg"
%%%

```lean (name := addType)
#check Nat.add
```
```leanOutput addType
Nat.add : Nat → Nat → Nat
```

Το βέλος `→` *δένει από δεξιά*, οπότε ο τύπος διαβάζεται:

$$`\mathsf{Nat} \to (\mathsf{Nat} \to \mathsf{Nat}) \qquad\text{και όχι}\qquad (\mathsf{Nat} \to \mathsf{Nat}) \to \mathsf{Nat}`

Δηλαδή η `Nat.add` παίρνει *έναν* φυσικό και επιστρέφει *μια συνάρτηση* `Nat → Nat`.
Αυτός ο τρόπος να γράφουμε συναρτήσεις πολλών ορισμάτων ως αλυσίδα συναρτήσεων ενός
ορίσματος λέγεται *currying* (από τον λογικό Haskell Curry).

# Διαδοχικές εφαρμογές

%%%
tag := "1-8-apps"
%%%

```lean (name := addPartial)
#check Nat.add 5
```
```leanOutput addPartial
Nat.add 5 : Nat → Nat
```

```lean (name := addFull)
#check Nat.add 5 6
```
```leanOutput addFull
Nat.add 5 6 : Nat
```

:::figure (src := "e01/currying.svg") (caption := "Κάθε όρισμα «καταναλώνει» το πρώτο βέλος του τύπου.")
:::

Η μερική εφαρμογή `Nat.add 5` *δεν* είναι ημιτελής έκφραση. Είναι ένα κανονικό term,
μια συνάρτηση που προσθέτει 5:

```lean (name := add5)
def add5 : Nat → Nat := Nat.add 5
#eval add5 10
```
```leanOutput add5
15
```

# Και ο τύπος μιας συνάρτησης είναι term

%%%
tag := "1-8-type-is-term"
%%%

Αφού όλοι οι τύποι είναι terms, πρέπει να ισχύει και για το `Nat → Nat`:

```lean (name := arrowType)
#check (Nat → Nat)
```
```leanOutput arrowType
Nat → Nat : Type
```

Δηλαδή $`\vdash (\mathsf{Nat} \to \mathsf{Nat}) : \mathsf{Sort}\ 1`. Το `→` όμως *δεν* είναι
πρωτογενής κατασκευή του kernel. Είναι σύνταξη για κάτι γενικότερο, το `Expr.forallE`,
που το βλέπουμε στο επόμενο μάθημα.

# Ερωτήσεις κατανόησης

%%%
tag := "1-8-askiseis"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Τύποι μερικών εφαρμογών")
Αν `f : Nat → Bool → Nat → Bool`, ποιος είναι ο τύπος καθενός από τα παρακάτω;

`f`, `f 5`, `f 5 true`, `f 5 true 7`

::::solution
```lean
section
variable (f : Nat → Bool → Nat → Bool)
#check f
#check f 5
#check f 5 true
#check f 5 true 7
end
```

:::table +header
*
  * Term
  * Τύπος
*
  * `f`
  * `Nat → Bool → Nat → Bool`
*
  * `f 5`
  * `Bool → Nat → Bool`
*
  * `f 5 true`
  * `Nat → Bool`
*
  * `f 5 true 7`
  * `Bool`
:::

Οι τρεις πρώτες απαντήσεις που δόθηκαν ήταν σωστές. Στην τέταρτη δόθηκε `Nat`, αλλά το
σωστό είναι `Bool`: με κάθε όρισμα «φεύγει» ένα βέλος από αριστερά, και μένει ο τύπος
μετά το τελευταίο βέλος.
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Πού μπαίνουν οι παρενθέσεις;")
Είναι ίδιοι οι τύποι `Nat → Bool → Nat` και `(Nat → Bool) → Nat`; Αν όχι, τι είδους
όρισμα δέχεται η συνάρτηση σε κάθε περίπτωση;

:::solution
*Διαφορετικοί.* Η απάντηση που δόθηκε ήταν σωστή: στον `(Nat → Bool) → Nat` το
όρισμα είναι _το ίδιο μια συνάρτηση_.

* `Nat → Bool → Nat`: παίρνει έναν `Nat`, μετά έναν `Bool`, και δίνει `Nat`.
* `(Nat → Bool) → Nat`: παίρνει *μια συνάρτηση* `Nat → Bool` (π.χ. ένα κριτήριο) και δίνει `Nat`.

```lean (name := higher)
def countUpTo10 (p : Nat → Bool) : Nat :=
  (List.range 10).countP p

#eval countUpTo10 (fun n => n % 2 == 0)
```
```leanOutput higher
5
```

Οι συναρτήσεις είναι terms όπως όλα τα άλλα, και μπορούν να δίνονται ως ορίσματα σε
άλλες συναρτήσεις (_higher-order functions_).
:::
::::

:::callout (kind := "summary")
* Το `→` δένει από δεξιά: `A → B → C` σημαίνει `A → (B → C)`.
* *Currying:* οι συναρτήσεις πολλών ορισμάτων είναι αλυσίδες συναρτήσεων ενός ορίσματος.
* Η μερική εφαρμογή είναι κανονικό term. Κάθε όρισμα αφαιρεί ένα βέλος από αριστερά.
* Ο τύπος `A → B` είναι κι αυτός term (π.χ. `Nat → Nat : Type`).
:::
