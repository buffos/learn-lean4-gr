import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.15 — Lambda Typing Rule" =>

%%%
tag := "m1-15"
file := "1-15"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τον κανόνα _Lambda_ και να τον συγκρίνεις με τον κανόνα _Pi_.
* Να βρίσκεις τον τύπο εμφωλευμένων `lam` αναδρομικά.
* Να προσέχεις πώς αλλάζουν οι De Bruijn indices από το term στον τύπο του.
:::

# Ο κανόνας

%%%
tag := "1-15-rule"
%%%

$$`\dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \qquad \Gamma,\ x : A \vdash t : B}{\Gamma \vdash (\lambda\, x : A.\ t) : (\Pi\, x : A,\ B)}\ \textsf{(Lam)}`

Δύο προϋποθέσεις: το domain $`A` να είναι τύπος, και το body $`t` να έχει *κάποιον* τύπο
$`B` στο επεκταμένο context. Ο τύπος της `lam` είναι τότε ένα `forallE` φτιαγμένο από το $`A` και το $`B`.

# Lam και Pi δίπλα δίπλα

%%%
tag := "1-15-compare"
%%%

$$`\dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \quad \Gamma, x : A \vdash B : \mathsf{Sort}\ v}{\Gamma \vdash (\Pi\, x : A,\ B) : \mathsf{Sort}\ (\mathrm{imax}(u,v))}\textsf{(Pi)} \qquad \dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \quad \Gamma, x : A \vdash t : B}{\Gamma \vdash (\lambda\, x : A.\ t) : (\Pi\, x : A,\ B)}\textsf{(Lam)}`

:::table +header
*
  *
  * `forallE`
  * `lam`
*
  * Ελέγχει το domain
  * Ναι
  * Ναι
*
  * Επεκτείνει το context
  * Ναι
  * Ναι
*
  * Απαιτεί το body να είναι τύπος
  * Ναι
  * *Όχι*
*
  * Επιστρέφει
  * ένα `Sort`
  * ένα `forallE`
*
  * Χρησιμοποιεί `imax`
  * Ναι
  * Όχι
:::

```
inferType(forallE(x, A, B), Γ):        inferType(lam(x, A, t), Γ):
  sort(u) ← inferType(A, Γ)              sort(u) ← inferType(A, Γ)
  Γ'      ← extend(Γ, x : A)             Γ'      ← extend(Γ, x : A)
  sort(v) ← inferType(B, Γ')             B       ← inferType(t, Γ')
  return sort(imax(u, v))                return forallE(x, A, B)
```

# Η πολυμορφική ταυτοτική

%%%
tag := "1-15-poly-id"
%%%

Η ταυτοτική για _οποιονδήποτε_ τύπο: `fun (A : Sort 1) => fun (x : A) => x`. Εσωτερικά:

```
lam (A)
├── Sort 1
└── lam (x)
    ├── bvar 0      -- A
    └── bvar 0      -- x
```

:::::callout (kind := "exercise")
Εφάρμοσε αναδρομικά τον κανόνα Lam. Ποιο είναι το context για το εσωτερικό body; Ποιος
είναι ο τύπος του `x`, της εσωτερικής `lam`, και της εξωτερικής; (Ζητάμε τον ίδιο τον
τύπο της συνάρτησης, όχι το universe του.)

::::solution
Ο τύπος είναι το εξής δέντρο:

```
forallE (A)
├── Sort 1
└── forallE (x)
    ├── bvar 0      -- A
    └── bvar 1      -- A
```

:::figure (src := "e01/lam-type-indices.svg") (caption := "Αριστερά το term, δεξιά ο τύπος του. Το τελευταίο bvar 0 (το x) έγινε bvar 1 (το A): ο kernel δεν αντιγράφει το body, αλλά βρίσκει τον τύπο του.")
:::

Στο context $`(A : \mathsf{Sort}\ 1,\ x : A)` το `x` είναι `bvar 0`, ενώ ο *τύπος* του, το `A`, είναι `bvar 1`.

```lean (name := polyId)
#check fun (A : Type) => fun (x : A) => x
```
```leanOutput polyId
fun A x => x : (A : Type) → A → A
```
::::
:::::

:::callout (kind := "summary")
* *Lam:* αν $`A : \mathsf{Sort}\ u` και $`\Gamma, x : A \vdash t : B`, τότε $`\lambda x{:}A.\,t : \Pi x{:}A,\, B`.
* Ίδια διαχείριση context με το Pi, αλλά το body δεν χρειάζεται να είναι τύπος.
* Ο τύπος μιας `lam` είναι ένα `forallE` (όχι ένα Sort).
* Οι δείκτες στον τύπο μπορεί να διαφέρουν από αυτούς στο term.
:::
