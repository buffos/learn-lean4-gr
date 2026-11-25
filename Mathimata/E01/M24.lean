import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.24 — Ο γενικός μηχανισμός Substitution" =>

%%%
tag := "m1-24"
file := "1-24"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τον γενικό αλγόριθμο αντικατάστασης με τις τρεις περιπτώσεις.
* Να καταλάβεις γιατί το όρισμα μετατοπίζεται πριν μπει στη θέση του.
* Να ξέρεις τι είναι ένα _κλειστό_ term.
:::

# Τρεις περιπτώσεις για κάθε bvar

%%%
tag := "1-24-cases"
%%%

Αφαιρούμε τον binder με δείκτη $`d` και τον αντικαθιστούμε με το term $`a`. Για κάθε `bvar i`:

:::table +header
*
  * Περίπτωση
  * Ενέργεια
  * Γιατί
*
  * $`i < d`
  * μένει `bvar i`
  * αναφέρεται σε binder *μέσα* από αυτόν που αφαιρούμε
*
  * $`i = d`
  * γίνεται $`a`, μετατοπισμένο
  * αναφέρεται σε *αυτόν* που αφαιρούμε
*
  * $`i > d`
  * γίνεται `bvar (i − 1)`
  * αναφέρεται σε binder *έξω*, που τώρα είναι ένα βήμα πιο κοντά
:::

```
subst(bvar i, a, d) =
  if i < d then bvar i
  if i = d then shift(d, 0, a)
  if i > d then bvar (i - 1)

subst(app f b, a, d)    = app (subst(f, a, d)) (subst(b, a, d))
subst(lam x A t, a, d)  = lam x (subst(A, a, d)) (subst(t, a, d+1))
```

Η αρχική κλήση γίνεται με $`d = 0`. Είναι ο μαθηματικός πυρήνας της `Lean.Expr.instantiate1`:

```lean (name := inst1)
open Lean in
#eval (Expr.app (.const `Nat.succ []) (.bvar 0)).instantiate1 (.lit (.natVal 5))
```
```leanOutput inst1
Lean.Expr.app (Lean.Expr.const `Nat.succ []) (Lean.Expr.lit (Lean.Literal.natVal 5))
```

# Πού χρησιμοποιείται

%%%
tag := "1-24-where"
%%%

:::table +header
*
  * Μηχανισμός
  * Πού γίνεται αντικατάσταση
*
  * Dependent App (1.17)
  * στο codomain του `forallE`
*
  * Let rule (1.19)
  * στον τύπο του body
*
  * β-reduction (1.20)
  * στο body της `lam`
*
  * ζ-reduction (1.20)
  * στο body του `letE`
:::

Η αντικατάσταση δεν είναι βοηθητική λεπτομέρεια. Είναι ένας από τους *θεμελιώδεις μηχανισμούς*
της θεωρίας τύπων.

# Γιατί μετατοπίζουμε το όρισμα;

%%%
tag := "1-24-why-shift"
%%%

:::::callout (kind := "exercise")
Στη γραμμή `if i = d then shift(d, 0, a)`, γιατί δεν επιστρέφουμε απλώς το `a`; Και αν το `a`
είναι _κλειστό_ term, όπως το `5` ή το `Nat`, αλλάζει κάτι το `shift`;

::::solution
Για να απαντηθεί, χρειάζεται πρώτα η έννοια του *κλειστού term*.

*Κλειστό term:* ένα term που δεν αναφέρεται σε μεταβλητές έξω από τον εαυτό του. Τα `5`,
`Nat` και `fun (x : Nat) => x` είναι κλειστά. Το τελευταίο περιέχει μεταβλητή, αλλά ο binder
της είναι μέσα στο ίδιο το term. Το `lam(x, Nat, bvar 1)` *δεν* είναι κλειστό: το `bvar 1`
δείχνει κάπου έξω.

Το `a` φτιάχτηκε σε ένα πλαίσιο αναφοράς. Αν μπει *βαθύτερα* στο δέντρο, κάτω από $`d`
επιπλέον binders, οι αναφορές του προς τα έξω πρέπει να μετατοπιστούν κατά $`d`, αλλιώς θα
«πιαστούν» (variable capture). Δεν ξέρουμε εκ των προτέρων αν το `a` έχει τέτοιες αναφορές,
οπότε εφαρμόζουμε πάντα το `shift`:

:::table +header
*
  * Όρισμα `a`
  * Αποτέλεσμα του shift
*
  * `5`, `Nat`
  * καμία αλλαγή (κλειστά)
*
  * `lam(x, Nat, bvar 0)`
  * καμία αλλαγή (το cutoff προστατεύει το `x`)
*
  * `bvar 0`
  * μετατόπιση
*
  * `lam(x, Nat, bvar 1)`
  * μετατόπιση της εξωτερικής αναφοράς
:::

*Για κλειστά terms το shift δεν αλλάζει τίποτα.* Μετράει μόνο για terms με ελεύθερες αναφορές.
::::
:::::

::::callout (kind := "exercise") (title := "Μια μικρή επαλήθευση")
Το `lam (x) (Nat) (app (app Nat.add (bvar 1)) (bvar 0))` μεταφέρεται κάτω από *δύο* νέους
εξωτερικούς binders. Τι γίνονται τα `bvar 0` και `bvar 1`;

:::solution
* `bvar 0` → *`bvar 0`*: αναφέρεται στο δικό του `x`.
* `bvar 1` → *`bvar 3`*: εξωτερική αναφορά, και παρεμβάλλονται δύο νέοι binders.
:::
::::

:::callout (kind := "summary")
* Για κάθε `bvar i`: αν $`i<d` μένει, αν $`i=d` γίνεται $`\mathrm{shift}(d,0,a)`, αν $`i>d` γίνεται `bvar (i−1)`.
* Μέσα σε binder, το $`d` ανεβαίνει κατά 1.
* Το όρισμα μετατοπίζεται για να μην «πιαστούν» οι ελεύθερες αναφορές του.
* Για κλειστά terms το shift δεν κάνει τίποτα.
:::
