import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.13 — Το scope των Bound Variables" =>

%%%
tag := "m1-13"
file := "1-13"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις ότι ο ίδιος δείκτης μπορεί να σημαίνει διαφορετική μεταβλητή.
* Να ξεχωρίζεις: `Expr` ↔ _well-scoped_ ↔ _well-typed_.
* Να ξέρεις πότε μια μεταβλητή δηλώνεται ως `A : Sort u`.
* Να ξεχωρίζεις _type formation_ (είναι τύπος;) από _type inhabitation_ (υπάρχει term;).
:::

# Ο ίδιος δείκτης, άλλη μεταβλητή

%%%
tag := "1-13-same-index"
%%%

Το `(A : Sort 1) → (B : Sort 1) → (x : A) → B` γίνεται:

```
forallE (A)
├── Sort 1
└── forallE (B)
    ├── Sort 1
    └── forallE (x)
        ├── bvar 1     -- A
        └── bvar 1     -- B
```

Δύο `bvar 1`, που αναφέρονται σε *διαφορετικές* μεταβλητές! Σε κάθε θέση ισχύουν
διαφορετικοί binders:

:::table +header
*
  * Θέση
  * `bvar 0`
  * `bvar 1`
  * `bvar 2`
*
  * domain του `B`
  * `A`
  * —
  * —
*
  * domain του `x`
  * `B`
  * `A`
  * —
*
  * codomain του `x`
  * `x`
  * `B`
  * `A`
:::

:::callout (kind := "tip")
Ο δείκτης *δεν* είναι μόνιμο ID της μεταβλητής. Είναι η _σχετική απόσταση_ από τη θέση όπου
βρίσκεται. Θυμίζει τη στοίβα: το `bvar 0` είναι πάντα η κορυφή της.
:::

# Τρία διαφορετικά «έγκυρο»

%%%
tag := "1-13-three"
%%%

Μπορούμε να φτιάξουμε ένα `Expr` με δείκτη που δεν δείχνει πουθενά:

```lean
open Lean in
def bad : Expr := .forallE `A (.sort (.succ .zero)) (.bvar 1) .default
```

Αυτός είναι έγκυρος κώδικας Lean (φτιάχνουμε μια δομή δεδομένων), αλλά η έκφραση που
αναπαριστά *δεν* είναι έγκυρο term: το `bvar 1` δεν έχει binder.

:::table +header
*
  * Έννοια
  * Ερώτημα
*
  * `Lean.Expr`
  * Είναι μια δομή δεδομένων σωστά φτιαγμένη;
*
  * _Well-scoped_
  * Δείχνει κάθε `bvar` σε υπαρκτό binder;
*
  * _Well-typed_
  * Ικανοποιεί η έκφραση τους κανόνες τύπων;
:::

# Ερωτήσεις κατανόησης (1)

%%%
tag := "1-13-askiseis-1"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Scoped αλλά όχι typed")
```
forallE (A)
├── Sort 1
└── forallE (B)
    ├── bvar 0
    └── bvar 0
```

Σε ποια μεταβλητή αναφέρεται κάθε `bvar 0`; Είναι η έκφραση well-scoped; Είναι well-typed;

::::solution
Το πρώτο αναφέρεται στο `A`, το δεύτερο στο `B`, και η έκφραση είναι well-scoped.
Όμως *δεν είναι well-typed*, και εδώ είναι η παγίδα.

Η έκφραση είναι το `(A : Sort 1) → (B : A) → B`. Στο codomain ισχύει $`\Gamma \vdash B : A`,
αλλά για να είναι το codomain τύπος χρειάζεται $`\Gamma \vdash B : \mathsf{Sort}\ v`. Το `A` δεν είναι Sort.
Είναι πάλι η *μη μεταβατικότητα* του 1.5.

```lean +error (name := notTyped)
#check (A : Type) → (B : A) → B
```
```leanOutput notTyped (severity := Lean.MessageSeverity.error)
type expected, got
  (B : A)
```

:::table +header
*
  * Έκφραση
  * Well-scoped
  * Well-typed
*
  * `forallE(A, Sort 1, bvar 0)`
  * Ναι
  * Ναι
*
  * `forallE(A, Sort 1, bvar 1)`
  * Όχι
  * Όχι
*
  * `(A : Sort 1) → (B : A) → B`
  * Ναι
  * Όχι
:::

Το *scope* ρωτά «υπάρχει η μεταβλητή;». Το *typing* ρωτά «τη χρησιμοποιώ σωστά;».
::::
:::::

# Πότε μια μεταβλητή είναι Sort u;

%%%
tag := "1-13-when-sort"
%%%

Αν αλλάξουμε το τελευταίο `bvar 0` σε `bvar 1`, παίρνουμε το `(A : Sort 1) → (B : A) → A`,
που *είναι* well-typed: επιστρέφει `A`, και το `A` είναι `Sort 1`. Αυτό γεννά ένα καλό
ερώτημα: *πότε θέλουμε `Sort n` σε μια μεταβλητή;*

Δηλώνουμε `A : Sort u` όταν θέλουμε η μεταβλητή να *αναπαριστά έναν τύπο*, και όχι ένα στοιχείο:

:::table +header
*
  * Δήλωση
  * Πιθανές τιμές
*
  * `x : Nat`
  * `5`, `10`, `42`
*
  * `x : Bool`
  * `true`, `false`
*
  * `P : Sort 0`
  * `True`, `False`, άλλες προτάσεις
*
  * `A : Sort 1`
  * `Nat`, `Bool`, `String`, `Prop`
*
  * `A : Sort 2`
  * `Type`, `Nat → Type`
:::

Δεν υπάρχει ειδικός μηχανισμός για τις «μεταβλητές τύπων». Είναι ο ίδιος κανόνας παντού.
Γιατί απορρίπτεται το `(A : Sort 1) → (B : A) → B`; Βάλε `A = Nat`, `B = 5`: ο τύπος του
αποτελέσματος θα ήταν `5`, που δεν είναι τύπος. Με `→ A` στο τέλος θα ήταν `Nat`, κάτι απόλυτα λογικό.

# Type formation έναντι type inhabitation

%%%
tag := "1-13-inhabitation"
%%%

Το ότι ένας τύπος είναι *έγκυρος* δεν σημαίνει ότι *υπάρχει* term με αυτόν τον τύπο:

* *Type formation:* είναι το $`T` τύπος; Δηλαδή $`\Gamma \vdash T : \mathsf{Sort}\ u`.
* *Type inhabitation:* υπάρχει $`t` με $`\Gamma \vdash t : T`;

::::callout (kind := "exercise") (title := "Άσκηση 2 — Τι δέχεται, τι επιστρέφει;")
Τι δέχεται και τι επιστρέφει μια συνάρτηση τύπου `(A : Sort 1) → (B : Sort 1) → A → B`;

:::solution
Τρία ορίσματα, με τύπους *(Sort 1, Sort 1, A)*, και αποτέλεσμα τύπου `B`. Συχνό λάθος είναι
να γραφτούν οι τύποι ως (A, B, A): τα `A` και `B` είναι τα ίδια τα ορίσματα, όχι οι τύποι τους.

Αν υπήρχε τέτοια `f`, τότε `f Nat Bool 5 : Bool` και `f Bool Nat true : Nat`.
:::
::::

:::callout (kind := "mistake") (title := "Μπορούμε να φτιάξουμε μια τέτοια f;")
Η πρώτη σκέψη είναι συνήθως: «αν το B έχει έστω και ένα στοιχείο, φτιάχνουμε μια σταθερή
συνάρτηση». Σωστό, αλλά πρέπει να ξεχωρίσουμε το να *υπάρχει* ένα στοιχείο από το να το *έχουμε διαθέσιμο στο context*.
Στο `(A B : Sort 1) → A → B` δεν έχουμε κανένα `b : B`, και το `B` μπορεί να είναι *κενό*,
όπως το `Empty`. Τότε θα χρειαζόμασταν μια συνάρτηση `Nat → Empty`, που δεν υπάρχει.

Αν όμως πάρουμε το στοιχείο ως όρισμα, γίνεται:

```lean
def const' : (A : Type) → (B : Type) → (b : B) → (x : A) → B :=
  fun _ _ b _ => b
```
:::

:::::callout (kind := "exercise") (title := "Άσκηση 3 — Ποιοι τύποι κατοικούνται;")
Χωρίς πρόσθετες υποθέσεις, για ποιους από τους παρακάτω μπορούμε να φτιάξουμε term;

1. `(A : Sort 1) → A → A`
2. `(A : Sort 1) → A`
3. `(A : Sort 1) → (B : Sort 1) → A → B → A`
4. `(A : Sort 1) → (B : Sort 1) → A → B → B`

::::solution
*1, 3, 4.* Το 1 το ξεχνάει κανείς εύκολα, επειδή το δεύτερο όρισμα δεν έχει όνομα. Το `A → A` είναι το ίδιο με το `(x : A) → A`. Υπάρχει όρισμα, απλώς ανώνυμο.

:::table +header
*
  * #
  * Τελικό context
  * Ζητάμε
  * Διαθέσιμο
*
  * 1
  * `A, x : A`
  * `A`
  * `x` ✓
*
  * 2
  * `A`
  * `A`
  * — ✗
*
  * 3
  * `A, B, x : A, y : B`
  * `A`
  * `x` ✓
*
  * 4
  * `A, B, x : A, y : B`
  * `B`
  * `y` ✓
:::

```lean
def t1 : (A : Type) → A → A := fun _ x => x            -- η ταυτοτική
def t3 : (A B : Type) → A → B → A := fun _ _ x _ => x
def t4 : (A B : Type) → A → B → B := fun _ _ _ y => y
```
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 4 — Κατασκευή με εφαρμογή")
Στο `(A : Sort 1) → (B : Sort 1) → (A → B) → A → B` δεν έχουμε μεταβλητή τύπου `B`.
Μπορούμε να φτιάξουμε term τύπου `B`;

:::solution
*Ναι, το `f x`.* Από $`f : A \to B` και $`x : A` παίρνουμε $`f\,x : B`.

```lean
def apply' : (A B : Type) → (A → B) → A → B := fun _ _ f x => f x
```

Πρώτο παράδειγμα όπου *κατασκευάζουμε* term συνδυάζοντας άλλα. Όταν το `B` είναι πρόταση,
αυτό λέγεται *απόδειξη*: το `f x` είναι ακριβώς ο _modus ponens_.
:::
::::

:::callout (kind := "summary")
* Ο ίδιος δείκτης σημαίνει διαφορετική μεταβλητή σε διαφορετική θέση.
* `Expr` ⊋ well-scoped ⊋ well-typed.
* `A : Sort u` σημαίνει ότι το `A` αναπαριστά τύπο.
* Έγκυρος τύπος δεν σημαίνει κατοικημένος τύπος. Για να κατοικηθεί, χρειάζεται ένα term διαθέσιμο ή κατασκευάσιμο από το context.
:::
