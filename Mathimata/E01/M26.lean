import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.26 — Universe Polymorphism" =>

%%%
tag := "m1-26"
file := "1-26"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί χρειαζόμαστε συναρτήσεις γενικές *ως προς το universe*.
* Να γνωρίσεις όλους τους constructors του `Lean.Level`, και ιδιαίτερα το `Level.param`.
* Να ξεχωρίζεις τις παραμέτρους universe από τις μεταβλητές του context.
* Να υπολογίζεις τύπους *συμβολικά*, χωρίς να απλοποιείς το $`\mathrm{imax}` βιαστικά.
:::

# Το πρόβλημα

%%%
tag := "1-26-problem"
%%%

```lean
def identity1 : (A : Sort 1) → A → A := fun A x => x
```

Λειτουργεί για τους `Nat`, `Bool`, `String`. Για κάτι τύπου `Sort 2` θα χρειαζόμασταν
δεύτερη συνάρτηση, και για `Sort 3` τρίτη:

```lean
def identity2 : (A : Sort 2) → A → A := fun A x => x
def identity3 : (A : Sort 3) → A → A := fun A x => x
```

Ο μηχανισμός είναι ακριβώς ο ίδιος. Αλλάζει μόνο το universe level. Θέλουμε *μία* δήλωση για όλα.

# Η γλώσσα των universe levels

%%%
tag := "1-26-levels"
%%%

```lean (name := levelCtors)
#print Lean.Level
```

:::table +header
*
  * Constructor
  * Σημασία
*
  * `Level.zero`
  * το επίπεδο 0
*
  * `Level.succ`
  * το επόμενο επίπεδο
*
  * `Level.max`
  * το μέγιστο δύο επιπέδων
*
  * `Level.imax`
  * το «impredicative» μέγιστο (1.10)
*
  * `Level.param`
  * *παράμετρος* universe, π.χ. `u`
*
  * `Level.mvar`
  * metavariable, που χρησιμοποιεί ο elaborator
:::

Με το `Level.param` γράφουμε ένα level _χωρίς να ξέρουμε την τιμή του_:

```lean
open Lean in
def sortU : Expr := .sort (.param `u)     -- Sort u
```

# Η universe-polymorphic ταυτοτική

%%%
tag := "1-26-poly"
%%%

```lean (name := identityU)
universe u

def identityU : (A : Sort u) → A → A := fun _ x => x

#check @identityU
```
```leanOutput identityU
identityU : (A : Sort u_1) → A → A
```

Μία δήλωση, παραμετροποιημένη ως προς το universe level. (Η Lean το τυπώνει ως `u_1`.)
Έτσι είναι γραμμένη και η `id` της βιβλιοθήκης, που είδαμε στο 1.11 (`{α : Sort u_1} → α → α`).

```lean (name := idInst)
#check identityU Nat 5
#check identityU Type Nat
#check identityU Prop True
```
```leanOutput idInst
identityU Nat 5 : Nat
```

Η ίδια συνάρτηση δουλεύει σε `Sort 1`, `Sort 2` και `Sort 0`.

::::callout (kind := "mistake") (title := "Το u δεν είναι μεταβλητή του context")
*Δεν* έχουμε $`u : \mathsf{Nat}` στο $`\Gamma`. Το `u` είναι παράμετρος της «γλώσσας» των levels,
όχι term της θεωρίας τύπων. Υπάρχουν δύο διαφορετικά επίπεδα παραμετροποίησης:

:::table +header
*
  * Παράμετρος
  * Είδος
  * Εσωτερικά
*
  * `A`, `x`
  * terms (ορίσματα)
  * `Expr.bvar`
*
  * `u`
  * universe level
  * `Level.param`
:::
::::

# Συμβολικός υπολογισμός

%%%
tag := "1-26-symbolic"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Ο τύπος ως συνάρτηση του u")
Ποιος είναι ο τύπος του `(A : Sort u) → A → A`, ως συνάρτηση του `u`; (Προσοχή: δεν ξέρουμε
αν $`u = 0` ή $`u > 0`.)

::::solution
Η βιαστική απάντηση είναι `Sort (u + 1)`, αλλά ισχύει μόνο όταν $`u > 0`.

1. Εσωτερικό: $`A : \mathsf{Sort}\ u`, άρα $`(A \to A) : \mathsf{Sort}\ (\mathrm{imax}(u,u)) = \mathsf{Sort}\ u`.
2. Εξωτερικό: $`\mathsf{Sort}\ u : \mathsf{Sort}\ (u+1)` και $`(A \to A) : \mathsf{Sort}\ u`, άρα
   *$`\mathsf{Sort}\ (\mathrm{imax}(u+1, u))`*.

Δεν απλοποιείται, γιατί εξαρτάται από το $`u`:

$$`\mathrm{imax}(u+1, u) = \begin{cases} 0 & u = 0 \\ u + 1 & u > 0 \end{cases}`

:::table +header
*
  * u
  * Τύπος
*
  * 0
  * `Sort 0` (= `Prop`)
*
  * 1
  * `Sort 2`
*
  * 2
  * `Sort 3`
:::

```lean (name := symbolic)
#check (A : Sort u) → A → A
```
```leanOutput symbolic
(A : Sort u) → A → A : Sort (imax (u + 1) u)
```

Ο kernel κρατάει *συμβολικές* εκφράσεις levels χωρίς να ξέρει τις τιμές των παραμέτρων. Γι' αυτό
υπάρχουν οι constructors `max` και `imax` μέσα στο `Level`.
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Δύο παράμετροι")
Με `universe u v`, ποιο είναι το universe level του εσωτερικού `A → B` στο
`(A : Sort u) → (B : Sort v) → A → B`;

:::solution
*`Sort (imax u v)`*:

$$`A : \mathsf{Sort}\ u,\ B : \mathsf{Sort}\ v \vdash (A \to B) : \mathsf{Sort}\ (\mathrm{imax}(u, v))`

```lean (name := twoParams)
universe v
#check (A : Sort u) → (B : Sort v) → A → B
```
```leanOutput twoParams
(A : Sort u) → (B : Sort v) → A → B : Sort (imax (u + 1) (v + 1) u v)
```

Η Lean γράφει τα εμφωλευμένα `imax` συμπτυγμένα: το `imax (u + 1) (v + 1) u v` σημαίνει
$`\mathrm{imax}(u+1,\ \mathrm{imax}(v+1,\ \mathrm{imax}(u, v)))`, ένα `imax` για κάθε βέλος, από
έξω προς τα μέσα. Το τελευταίο, το $`\mathrm{imax}(u, v)`, είναι ακριβώς το εσωτερικό `A → B`.
:::
::::

:::callout (kind := "note") (title := "Τι ακολουθεί")
Πώς «γεμίζει» ο kernel το `u` με συγκεκριμένη τιμή, όταν γράφουμε `identityU Nat 5`; Αυτό είναι το
θέμα του επόμενου μαθήματος, _Universe Instantiation_, που θα προστεθεί σύντομα.
:::

:::callout (kind := "summary")
* Οι universe-polymorphic δηλώσεις (`universe u`) αποφεύγουν να γράφουμε την ίδια συνάρτηση για κάθε level.
* `Lean.Level` = zero | succ | max | imax | param | mvar.
* Το `u` είναι `Level.param`, όχι μεταβλητή του context.
* Οι τύποι υπολογίζονται συμβολικά, π.χ. $`\mathsf{Sort}\ (\mathrm{imax}(u+1,u))`. Δεν απλοποιούμε χωρίς να ξέρουμε αν $`u = 0`.
:::
