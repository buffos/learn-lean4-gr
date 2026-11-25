import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.17 — Dependent Application Rule" =>

%%%
tag := "m1-17"
file := "1-17"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί στην εξαρτημένη περίπτωση δεν αρκεί να επιστρέψουμε το codomain.
* Να ξέρεις τον γενικό κανόνα _App_, με αντικατάσταση $`B[x := a]`.
* Να βρίσκεις τον τύπο διαδοχικών εφαρμογών μιας πολυμορφικής συνάρτησης.
:::

# Το πρόβλημα

%%%
tag := "1-17-problem"
%%%

Πάρε την πολυμορφική ταυτοτική:

```lean
def f : (A : Type) → (x : A) → A := fun A x => x
```

Ο τύπος της είναι `forallE(A, Sort 1, forallE(x, bvar 0, bvar 1))`. Τι τύπο έχει το `f Nat`;

Αν επιστρέφαμε απλώς το body του εξωτερικού `forallE`, θα παίρναμε
`forallE(x, bvar 0, bvar 1)`: δείκτες που *δεν δείχνουν πουθενά*, γιατί ο binder `A`
εξαφανίστηκε. Πρέπει οι αναφορές στο `A` να *αντικατασταθούν* με το πραγματικό όρισμα `Nat`:

```lean (name := fNat)
#check f Nat
```
```leanOutput fNat
f Nat : Nat → Nat
```

Αυτό λέγεται *substitution* (αντικατάσταση).

# Ο γενικός κανόνας

%%%
tag := "1-17-rule"
%%%

$$`\dfrac{\Gamma \vdash f : \Pi\, x : A,\ B \qquad \Gamma \vdash a : A}{\Gamma \vdash f\ a : B[x := a]}\ \textsf{(App)}`

Το $`B[x := a]` σημαίνει: στο $`B`, αντικατάστησε τις αναφορές στη δεσμευμένη $`x` με το $`a`,
προσέχοντας σωστά το scope. Στη Lean αυτό το κάνει η `Lean.Expr.instantiate1`.

```
inferType(app(f, a), Γ):
  forallE(x, A, B) ← inferType(f, Γ)
  T ← inferType(a, Γ)
  if not defEq(T, A): error "type mismatch"
  return instantiate1(B, a)          -- πριν: return B
```

Όταν το $`B` δεν περιέχει το $`x` (μη εξαρτημένη περίπτωση), η αντικατάσταση δεν αλλάζει
τίποτα, και παίρνουμε τον κανόνα του 1.16.

# Παράδειγμα: διαδοχικές εφαρμογές

%%%
tag := "1-17-example"
%%%

:::::callout (kind := "exercise")
Αν `g : (A : Sort 1) → (B : Sort 1) → (A → B) → A → B`, βρες τους τύπους των `g`, `g Nat`,
`g Nat Bool`.

::::solution
Βήμα προς βήμα:

:::table +header
*
  * Term
  * Τύπος
  * Αντικατάσταση
*
  * `g`
  * `(A : Sort 1) → (B : Sort 1) → (A → B) → A → B`
  * —
*
  * `g Nat`
  * `(B : Sort 1) → (Nat → B) → Nat → B`
  * `A := Nat`
*
  * `g Nat Bool`
  * `(Nat → Bool) → Nat → Bool`
  * `B := Bool`
:::

```lean (name := gApps)
section
variable (g : (A : Type) → (B : Type) → (A → B) → A → B)
#check g Nat
#check g Nat Bool
end
```
```leanOutput gApps
g Nat : (B : Type) → (Nat → B) → Nat → B
```

:::figure (src := "e01/dep-app.svg") (caption := "Κάθε εφαρμογή «τρώει» το εξωτερικό forallE και γράφει το όρισμα σε κάθε σημείο όπου εμφανιζόταν η αντίστοιχη bvar. Στο τέλος δεν μένει καμία bvar.")
:::

Ο kernel *μετασχηματίζει τον τύπο* της συνάρτησης για να βρει τον τύπο της εφαρμογής.
Δεν χρειάζεται να *εκτελέσει* τη συνάρτηση.
::::
:::::

:::callout (kind := "note") (title := "Αρκετά με τα δέντρα στο χέρι")
Το να γράφεις αυτά τα δέντρα με το χέρι είναι κουραστικό. Αρκεί να καταλάβεις τον μηχανισμό.
Τη μηχανική δουλειά την κάνει η Lean για εμάς:

```lean
section
variable (h : (A : Type) → A → A → A)
#check h Nat        -- Nat → Nat → Nat
#check h Nat 5      -- Nat → Nat
#check h Nat 5 7    -- Nat
end
```
:::

:::callout (kind := "summary")
* *App (γενικός):* αν $`f : \Pi x{:}A,\, B` και $`a : A`, τότε $`f\,a : B[x := a]`.
* Χωρίς αντικατάσταση, θα έμεναν «ορφανές» `bvar`.
* Κάθε εφαρμογή αφαιρεί ένα εξωτερικό `forallE` και αντικαθιστά τον binder του.
* Ο type checker μετασχηματίζει *τύπους*, δεν εκτελεί συναρτήσεις.
:::
