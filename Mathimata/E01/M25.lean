import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.25 — Substitution και Shifting στην πράξη" =>

%%%
tag := "m1-25"
file := "1-25"
number := false
%%%

:::callout (kind := "goals")
* Να εκτελέσεις βήμα προς βήμα μια β-reduction όπου το shifting είναι απαραίτητο.
* Να δεις πώς η παράλειψή του προκαλεί variable capture.
:::

# Το παράδειγμα

%%%
tag := "1-25-example"
%%%

```lean
#check fun (z : Nat) => (fun (x : Nat) => fun (_y : Nat) => x) z
```

```
lam (z)
├── Nat
└── app
    ├── lam (x)
    │   ├── Nat
    │   └── lam (y)
    │       ├── Nat
    │       └── bvar 1     -- x
    └── bvar 0             -- z
```

Θέλουμε β-reduction στην `app`. Είναι ακριβώς το παράδειγμα του 1.21, γραμμένο με δείκτες.

# Βήμα προς βήμα

%%%
tag := "1-25-steps"
%%%

:::table +header
*
  * Βήμα
  * Τι γίνεται
*
  * 1. Όρισμα
  * $`a = \mathsf{bvar}\ 0` (το `z`)
*
  * 2. Αναζήτηση
  * Ξεκινάμε στο body της `lam (x)` με $`d = 0`. Μπαίνοντας στη `lam (y)`, $`d = 1`. Βρίσκουμε `bvar 1`: $`i = d`.
*
  * 3. Shift
  * $`\mathrm{shift}(1, 0, \mathsf{bvar}\ 0) = \mathsf{bvar}\ 1`
*
  * 4. Αποτέλεσμα
  * `lam (z) (Nat) (lam (y) (Nat) (bvar 1))`
:::

:::figure (src := "e01/subst-practice.svg") (caption := "Με shift το z διατηρείται (bvar 1). Χωρίς shift θα γινόταν bvar 0, δηλαδή το y: variable capture.")
:::

Αποτέλεσμα: `fun (z : Nat) => fun (y : Nat) => z`. Η αναφορά στο `z` διατηρήθηκε.

```lean
example : (fun (z : Nat) => (fun (x : Nat) => fun (_ : Nat) => x) z)
        = (fun (z : Nat) => fun (_ : Nat) => z) := rfl
```

# Χωρίς shift

%%%
tag := "1-25-without"
%%%

Αν επιστρέφαμε απλώς το `a`, θα παίρναμε `fun z => fun y => y` αντί για `fun z => fun y => z`.
Είναι *ακριβώς* το variable capture του 1.21. Το `shift(d, 0, a)` στον αλγόριθμο υπάρχει γι' αυτό
ακριβώς τον λόγο.

:::callout (kind := "deep") (title := "Γιατί η Lean δουλεύει έτσι;")
Θα μπορούσε κανείς να κρατάει ονόματα και να μετονομάζει όπου χρειάζεται. Οι De Bruijn indices
όμως κάνουν την α-ισοδυναμία *δωρεάν* (ίδια δέντρα) και την αντικατάσταση *μηχανική*, χωρίς
αναζήτηση «φρέσκων» ονομάτων. Στην πράξη η Lean συνδυάζει δύο ιδέες, το λεγόμενο _locally nameless_:
`bvar` για τις δεσμευμένες μεταβλητές, και `fvar` (ελεύθερες μεταβλητές με μοναδικό ID) όταν
«ανοίγει» έναν binder για να ελέγξει το body του.
:::

:::callout (kind := "summary")
* Όταν το όρισμα περιέχει αναφορές (π.χ. `bvar 0`) και μπαίνει κάτω από binders, πρέπει να μετατοπιστεί.
* Χωρίς shift εμφανίζεται variable capture: το `z` γίνεται `y`.
* Οι De Bruijn indices κάνουν την αντικατάσταση μηχανική, και τη σωστή μετατόπιση υποχρεωτική.
:::
