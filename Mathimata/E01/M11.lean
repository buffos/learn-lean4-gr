import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.11 — Dependent Function Types (Π-types)" =>

%%%
tag := "m1-11"
file := "1-11"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις τι είναι ένας _εξαρτημένος_ τύπος συνάρτησης $`\Pi\,x : A,\ B(x)`.
* Να ξέρεις τον γενικό κανόνα του `forallE`, όπου το codomain ελέγχεται σε *επεκταμένο* context.
* Να παρακολουθείς πώς αλλάζει το context σε κάθε κόμβο του δέντρου.
:::

# Όταν ο τύπος του αποτελέσματος εξαρτάται από το όρισμα

%%%
tag := "1-11-idea"
%%%

Ως τώρα, στο `A → B` ο τύπος `B` ήταν ανεξάρτητος από το όρισμα. Το `forallE` όμως έχει
και *όνομα* ορίσματος, επειδή στη Lean ο τύπος του αποτελέσματος μπορεί να *εξαρτάται από
την τιμή του ορίσματος*. Στα μαθηματικά αυτό λέγεται *Π-type*:

$$`\Pi\, x : A,\ B(x) \qquad\qquad\text{στη Lean:}\quad (x : A) \to B\ x`

Το `A → B` είναι απλώς η ειδική περίπτωση όπου το `B` δεν περιέχει το `x`.

```lean (name := piType)
#check (A : Type) → A
```
```leanOutput piType
(A : Type) → A : Type 1
```

Ένας τέτοιος τύπος περιγράφει συναρτήσεις που παίρνουν *έναν τύπο* `A` και επιστρέφουν
*ένα στοιχείο του `A`*. Ο τύπος του αποτελέσματος αλλάζει ανάλογα με το όρισμα:

:::table +header
*
  * Όρισμα
  * Τύπος αποτελέσματος
*
  * `Nat`
  * `Nat`
*
  * `Bool`
  * `Bool`
*
  * `String`
  * `String`
:::

(Εδώ φτιάχνουμε μόνο τον _τύπο_. Δεν ισχυριζόμαστε ότι υπάρχει συνάρτηση με αυτόν τον τύπο.)

:::callout (kind := "tip") (title := "Ένα πραγματικό παράδειγμα")
Η ταυτοτική συνάρτηση της βιβλιοθήκης είναι ακριβώς ένας εξαρτημένος τύπος:

```lean (name := idType)
#check @id
```
```leanOutput idType
@id : {α : Sort u_1} → α → α
```

Δέχεται έναν τύπο `α` (μέσα σε `{}`, δηλαδή τον συμπεραίνει μόνη της η Lean) και επιστρέφει
μια συνάρτηση `α → α`. Το `{}` είναι το `BinderInfo` που αφήσαμε στην άκρη στο 1.9.
:::

# Ο γενικός κανόνας του forallE

%%%
tag := "1-11-rule"
%%%

$$`\dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \qquad \Gamma,\ x : A \vdash B : \mathsf{Sort}\ v}{\Gamma \vdash (\Pi\, x : A,\ B) : \mathsf{Sort}\ (\mathrm{imax}(u, v))}\ \textsf{(Pi)}`

Σε σχέση με τον κανόνα Arrow του 1.10 υπάρχει *μία* αλλαγή: το codomain $`B` ελέγχεται στο
*επεκταμένο* context $`\Gamma, x : A`. Γι' αυτό το $`B` μπορεί να αναφέρεται στο $`x`.

```
inferType(forallE(x, A, B), Γ):
  sort(u) ← inferType(A, Γ)
  Γ'      ← extend(Γ, x : A)
  sort(v) ← inferType(B, Γ')
  return sort(imax(u, v))
```

# Ερωτήσεις κατανόησης

%%%
tag := "1-11-askiseis"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 1 — Βήμα προς βήμα")
Για το `(A : Sort 1) → A`, με κενό αρχικό context, βρες:
1. τον τύπο του domain `Sort 1`,
2. το επεκταμένο context για το codomain,
3. τον τύπο του codomain `A` σε αυτό,
4. τον τύπο όλης της έκφρασης.

:::solution
Η απάντηση που δόθηκε ήταν _«Sort 1, A : Sort 1, Sort 1, Sort 1»_. Τα 2 και 3 είναι σωστά.
Στο 1 μπήκε ξανά _το term στη θέση του τύπου του_:

1. $`\varnothing \vdash \mathsf{Sort}\ 1 : \mathsf{Sort}\ 2`, άρα $`u = 2` (όχι 1).
2. $`\Gamma' = (A : \mathsf{Sort}\ 1)`. Στο context μπαίνει ο _δηλωμένος_ τύπος του `A`, όχι ο τύπος του τύπου του.
3. $`A : \mathsf{Sort}\ 1 \vdash A : \mathsf{Sort}\ 1` (Var), άρα $`v = 1`.
4. $`\mathrm{imax}(2, 1) = 2`, άρα *`Sort 2`* (= `Type 1`, όπως έδειξε και το `#check` παραπάνω).
:::
::::

:::::callout (kind := "exercise") (title := "Άσκηση 2 — Contexts και τύποι σε κάθε κόμβο")
Για το `(A : Sort 1) → (x : A) → A`, συμπλήρωσε για κάθε κόμβο το context και τον τύπο του.

::::solution
Το τελικό `Sort 2` που δόθηκε ήταν σωστό, αλλά με δύο λάθη στα ενδιάμεσα contexts (στο
εσωτερικό domain δόθηκε κενό context, και στο εσωτερικό codomain λείπει το `x : A`), καθώς και
ένα λάθος στον εσωτερικό υπολογισμό ($`\max(2,1)` αντί για $`\mathrm{imax}(1,1)`).

:::table +header
*
  * Κόμβος
  * Context
  * Τύπος
*
  * `Sort 1` (εξωτ. domain)
  * $`\varnothing`
  * `Sort 2`
*
  * `A` (εσωτ. domain)
  * `A : Sort 1`
  * `Sort 1`
*
  * `A` (εσωτ. codomain)
  * `A : Sort 1, x : A`
  * `Sort 1`
*
  * εσωτερικό `forallE`
  * `A : Sort 1`
  * `Sort 1`
*
  * εξωτερικό `forallE`
  * $`\varnothing`
  * `Sort 2`
:::

:::figure (src := "e01/pi-contexts.svg") (caption := "Κάθε forallE επεκτείνει το context μόνο για το δικό του codomain, και η επέκταση κληρονομείται προς τα κάτω.")
:::
::::
:::::

:::::callout (kind := "exercise") (title := "Άσκηση 3 — Μόνο τα contexts")
Στο `(A : Sort 1) → (B : Sort 2) → (x : A) → B`, ποιο context είναι διαθέσιμο σε καθέναν
από τους τέσσερις τερματικούς κόμβους `Sort 1`, `Sort 2`, `A`, `B`;

::::solution
Σωστά και τα τέσσερα:

:::table +header
*
  * Κόμβος
  * Context
*
  * `Sort 1`
  * $`\varnothing`
*
  * `Sort 2`
  * `A : Sort 1`
*
  * `A`
  * `A : Sort 1, B : Sort 2`
*
  * `B`
  * `A : Sort 1, B : Sort 2, x : A`
:::

Το context δεν είναι ένα, κοινό για όλο το δέντρο. *Εξαρτάται από τη διαδρομή* που
ακολουθεί ο kernel κατά την αναδρομή.
::::
:::::

:::callout (kind := "summary")
* *Π-type:* $`(x : A) \to B\,x`. Το `A → B` είναι η ειδική περίπτωση όπου το $`B` δεν περιέχει το $`x`.
* *Pi rule:* το domain ελέγχεται στο $`\Gamma`, το codomain στο $`\Gamma, x : A`, και ο τύπος είναι $`\mathsf{Sort}\ (\mathrm{imax}(u,v))`.
* Το context αλλάζει κατά μήκος της διαδρομής στο δέντρο.
:::
