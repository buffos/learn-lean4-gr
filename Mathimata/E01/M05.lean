import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.5 — Η εγκυρότητα του Context" =>

%%%
tag := "m1-5"
file := "1-5"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί η σειρά των δηλώσεων στο context μετράει.
* Να ξέρεις τους κανόνες _well-formedness_ ($`\mathsf{wf}`) του context.
* Να εφαρμόζεις τις δύο θεμελιώδεις αρχές: *μη μεταβατικότητα* και *εγκυρότητα τύπου*.
:::

# Το context είναι διατεταγμένο

%%%
tag := "1-5-order"
%%%

Σύγκρινε:

$$`\Gamma_1 = (A : \mathsf{Sort}\ 1,\ x : A) \qquad\qquad \Gamma_2 = (x : A,\ A : \mathsf{Sort}\ 1)`

Το $`\Gamma_1` είναι έγκυρο. Το $`\Gamma_2` όχι: όταν δηλώνεται το `x : A`, το `A` δεν
υπάρχει ακόμη. Κάθε νέα δήλωση ελέγχεται *με βάση μόνο όσα δηλώθηκαν πριν από αυτήν*.
Γι' αυτό το context είναι _ακολουθία_ και όχι σύνολο.

# Κατασκευή βήμα προς βήμα

%%%
tag := "1-5-steps"
%%%

:::figure (src := "e01/context-build.svg") (caption := "Το context χτίζεται μία δήλωση τη φορά. Σε κάθε βήμα ελέγχεται ότι ο νέος τύπος είναι πράγματι τύπος, μέσα στο context που υπάρχει ως τότε.")
:::

1. Ξεκινάμε από το κενό context $`\Gamma_0 = ()`.
2. Για να προσθέσουμε `A : Sort 1`, ο kernel ελέγχει ότι το `Sort 1` είναι τύπος:
   $`\Gamma_0 \vdash \mathsf{Sort}\ 1 : \mathsf{Sort}\ 2` (κανόνας Sort). Έτσι προκύπτει το $`\Gamma_1 = (A : \mathsf{Sort}\ 1)`.
3. Για να προσθέσουμε `x : A`, ελέγχει ότι το `A` είναι τύπος:
   $`\Gamma_1 \vdash A : \mathsf{Sort}\ 1` (κανόνας Var). Έτσι προκύπτει το $`\Gamma_2 = (A : \mathsf{Sort}\ 1,\ x : A)`.

# Οι κανόνες well-formedness

%%%
tag := "1-5-wf"
%%%

Λέμε ότι ένα έγκυρο context είναι *well-formed* και γράφουμε $`\Gamma\ \mathsf{wf}`. Υπάρχουν δύο κανόνες:

$$`\dfrac{}{\ \varnothing\ \mathsf{wf}\ }\ \textsf{(Empty)} \qquad\qquad \dfrac{\Gamma\ \mathsf{wf} \qquad \Gamma \vdash T : \mathsf{Sort}\ u}{(\Gamma,\ x : T)\ \mathsf{wf}}\ \textsf{(Extend)}`

(με την προϋπόθεση ότι το $`x` είναι καινούργιο όνομα). Η επέκταση έχει δύο προϋποθέσεις:
το υπάρχον context να είναι έγκυρο, και το $`T` να είναι έγκυρος τύπος _μέσα σε αυτό_.

:::callout (kind := "tip")
Δεν χρειάστηκε κανένας νέος μηχανισμός για τους τύπους των μεταβλητών. Ο κανόνας
Extend χρησιμοποιεί ξανά τον κανόνα εγκυρότητας τύπου του 1.2: $`\Gamma \vdash T : \mathsf{Sort}\ u`.
:::

Στη Lean:

```lean
section
variable (A : Sort 1)
variable (x : A)
variable (y : A)
end
```

Αυτό είναι έγκυρο. Το επόμενο όμως όχι, γιατί το `x` δεν είναι τύπος:

```lean +error (name := badCtx)
section
variable (x : Nat)
variable (y : x)
end
```
```leanOutput badCtx (severity := Lean.MessageSeverity.error)
type expected, got
  (x : Nat)
```

# Ερωτήσεις κατανόησης

%%%
tag := "1-5-askiseis"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Ποια contexts είναι έγκυρα;")
1. $`A : \mathsf{Sort}\ 1,\ x : A,\ y : A`
2. $`A : \mathsf{Sort}\ 1,\ x : A,\ y : x`
3. $`A : \mathsf{Sort}\ 2,\ B : A,\ x : B`
4. $`A : \mathsf{Sort}\ 1,\ P : \mathsf{Sort}\ 0,\ h : P`

Για όσα δεν είναι έγκυρα: σε ποια δήλωση αποτυγχάνει η κατασκευή, και γιατί; Πρόσεξε
ιδιαίτερα το 3: αλλάζει κάτι επειδή ξεκινάμε από ψηλότερο universe;

::::solution
*Έγκυρα: 1 και 4. Μη έγκυρα: 2 και 3.*

Το 2 αποτυγχάνει στο `y : x`, γιατί το `x` δεν είναι τύπος. Το 3 είναι η παγίδα: πολλοί το
θεωρούν έγκυρο, επειδή «ξεκινάμε από ψηλό universe». *Δεν είναι:*

* `A : Sort 2`: έγκυρο, γιατί $`\mathsf{Sort}\ 2 : \mathsf{Sort}\ 3`.
* `B : A`: έγκυρο, γιατί $`\Gamma \vdash A : \mathsf{Sort}\ 2`, άρα το `A` είναι τύπος.
* `x : B`: *αποτυγχάνει.* Για να είναι το `B` τύπος, χρειαζόμαστε $`\Gamma \vdash B : \mathsf{Sort}\ u`.
  Όμως ο τύπος του `B` είναι το `A`, μια τοπική μεταβλητή που δεν είναι Sort.

```lean +error (name := ctx3)
section
variable (A : Sort 2) (B : A) (x : B)
end
```
```leanOutput ctx3 (severity := Lean.MessageSeverity.error)
type expected, got
  (B : A)
```

Το universe level του `A` *δεν* μας επιτρέπει να συμπεράνουμε ότι τα terms με τύπο `A`
είναι τύποι:

:::table +header
*
  * Δηλώσεις
  * Τύπος του B
  * Είναι το B τύπος;
*
  * `A : Sort 1, B : A`
  * `A`
  * Όχι
*
  * `A : Sort 2, B : A`
  * `A`
  * Όχι
*
  * `A : Sort 3, B : A`
  * `A`
  * Όχι
*
  * `B : Sort 2`
  * `Sort 2`
  * Ναι
:::
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Ίδιος τύπος, διαφορετικό αποτέλεσμα")
Το `(A : Sort 2) (B : A) (x : B)` απορρίπτεται, ενώ το `(A : Sort 2) (B : Sort 1) (x : B)`
είναι έγκυρο. Όμως και το `A` και το `Sort 1` έχουν τύπο `Sort 2`. Γιατί η αντικατάσταση
του `A` με το `Sort 1` αλλάζει το αποτέλεσμα;

:::solution
*Η σχέση typing ($`:`) δεν είναι μεταβατική.*

Στη μία περίπτωση $`B : \mathsf{Sort}\ 1`, που είναι Sort, άρα το `B` είναι τύπος.
Στην άλλη $`B : A`, που δεν είναι Sort, άρα το `B` δεν είναι τύπος. Ο kernel κοιτάζει
μόνο τον *άμεσο* τύπο του `B`, όχι ολόκληρη την αλυσίδα από πάνω του.
:::
::::

:::figure (src := "e01/two-principles.svg") (caption := "Οι δύο αρχές που εξηγούν όλα τα παραδείγματα ως εδώ.")
:::

:::callout (kind := "summary")
* Το context χτίζεται με τη σειρά. Κάθε δήλωση ελέγχεται με βάση τις προηγούμενες.
* $`\varnothing\ \mathsf{wf}`, και $`(\Gamma, x : T)\ \mathsf{wf}` αν $`\Gamma\ \mathsf{wf}` και $`\Gamma \vdash T : \mathsf{Sort}\ u`.
* *Μη μεταβατικότητα:* από $`a : B` και $`B : C` δεν προκύπτει $`a : C`.
* *Εγκυρότητα τύπου:* το $`T` είναι τύπος όταν $`\Gamma \vdash T : \mathsf{Sort}\ u`.
:::
