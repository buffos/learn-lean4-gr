import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.10 — Typing Rule των Function Types" =>

%%%
tag := "m1-10"
file := "1-10"
number := false
%%%

:::callout (kind := "goals")
* Να εφαρμόζεις τον κανόνα για τύπους συναρτήσεων με την πράξη $`\mathrm{imax}`.
* Να καταλάβεις γιατί $`\mathrm{imax}` και όχι $`\max` (το `Prop` είναι ιδιαίτερο).
* Να υπολογίζεις τον τύπο εμφωλευμένων `forallE` *αναδρομικά*, χωρίς να κάνεις διπλό βήμα.
:::

# Ο κανόνας

%%%
tag := "1-10-rule"
%%%

Γιατί `#check (Nat → Bool)` δίνει `Type`; Ο kernel βλέπει `forallE(Nat, Bool)` και πρέπει:

1. να ελέγξει ότι το domain και το codomain είναι *τύποι*, και
2. να βρει σε ποιο universe ανήκει ο τύπος της συνάρτησης.

Για *μη εξαρτημένους* τύπους συναρτήσεων (τη γενική μορφή θα τη δούμε στο 1.11):

$$`\dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \qquad \Gamma \vdash B : \mathsf{Sort}\ v}{\Gamma \vdash (A \to B) : \mathsf{Sort}\ (\mathrm{imax}(u, v))}\ \textsf{(Arrow)}`

όπου η $`\mathrm{imax}` είναι μια πράξη πάνω στα universe levels (`Lean.Level.imax`):

$$`\mathrm{imax}(u, v) = \begin{cases} 0 & \text{αν } v = 0 \\ \max(u, v) & \text{αν } v > 0 \end{cases}`

# Ένα πλήρες derivation

%%%
tag := "1-10-derivation"
%%%

Για το `Nat → Bool`: $`u = 1`, $`v = 1`, $`\mathrm{imax}(1,1) = 1`. Ολόκληρο το δέντρο τεκμηρίωσης:

$$`\dfrac{\dfrac{(\mathsf{Nat} : \mathsf{Sort}\ 1) \in \Sigma}{\Gamma \vdash \mathsf{Nat} : \mathsf{Sort}\ 1}\textsf{Const} \qquad \dfrac{(\mathsf{Bool} : \mathsf{Sort}\ 1) \in \Sigma}{\Gamma \vdash \mathsf{Bool} : \mathsf{Sort}\ 1}\textsf{Const}}{\Gamma \vdash (\mathsf{Nat} \to \mathsf{Bool}) : \mathsf{Sort}\ 1}\ \textsf{Arrow}`

Δύο εφαρμογές του Const και μία του Arrow. Έτσι οι απλοί κανόνες συνδυάζονται για να
ελεγχθούν σύνθετες εκφράσεις.

# Ερωτήσεις κατανόησης (1)

%%%
tag := "1-10-askiseis-1"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Σε ποιο Sort;")
Με `Nat : Sort 1`, `Sort 1 : Sort 2`, `True : Sort 0`, βρες τον τύπο των:

1. `Nat → Nat`
2. `Nat → Sort 1`
3. `Sort 1 → Nat`
4. `Nat → True`
5. `True → Nat`

::::solution
Η απάντηση που δόθηκε ήταν _«1, 1, 1, 0, 1»_. Τα 1, 4, 5 είναι σωστά, αλλά τα *2 και 3 είναι `Sort 2`*.

:::table +header
*
  * Τύπος
  * u
  * v
  * imax
  * Αποτέλεσμα
*
  * `Nat → Nat`
  * 1
  * 1
  * 1
  * `Sort 1` ✓
*
  * `Nat → Sort 1`
  * 1
  * *2*
  * 2
  * `Sort 2` ✗
*
  * `Sort 1 → Nat`
  * *2*
  * 1
  * 2
  * `Sort 2` ✗
*
  * `Nat → True`
  * 1
  * 0
  * 0
  * `Sort 0` ✓
*
  * `True → Nat`
  * 0
  * 1
  * 1
  * `Sort 1` ✓
:::

```lean (name := imaxCheck)
#check (Nat → Sort 1)
#check (Nat → True)
```
```leanOutput imaxCheck
Nat → Type : Type 1
```
::::
:::::

:::callout (kind := "mistake") (title := "Δεν παίρνουμε το level που είναι γραμμένο")
Στο `Nat → Sort 1` το `1` που φαίνεται *δεν* είναι το $`v`. Ο kernel πρώτα *βρίσκει τον τύπο*
κάθε πλευράς ($`\mathsf{Sort}\ 1 : \mathsf{Sort}\ 2`, άρα $`v = 2`) και μετά εφαρμόζει $`\mathrm{imax}`.
:::

# Γιατί imax και όχι max;

%%%
tag := "1-10-why-imax"
%%%

Η $`\mathrm{imax}` *δεν είναι αντιμεταθετική*:

$$`\mathrm{imax}(1, 0) = 0 \qquad\qquad \mathrm{imax}(0, 1) = 1`

Αυτό σημαίνει ότι *όταν το codomain είναι πρόταση (`Prop`), ολόκληρος ο τύπος της συνάρτησης
είναι πρόταση*, όσο «μεγάλο» κι αν είναι το domain:

```lean (name := impred)
#check (Sort 30 → True)
```
```leanOutput impred
∀ (a : Type 29), True : Prop
```

Πρόσεξε πώς το τύπωσε η Lean: όταν το αποτέλεσμα είναι πρόταση, γράφει το βέλος ως *`∀`*.
Είναι το ίδιο `forallE` (εξ ου και το όνομα!): ένας τύπος συνάρτησης προς `Prop` _είναι_ μια
πρόταση «για κάθε».

:::callout (kind := "note") (title := "Γιατί όχι Sort 100;")
Στη θεωρία, ο κανόνας ισχύει για κάθε level. Η Lean όμως, από πρακτική άποψη, δεν δέχεται
αριθμητικά levels πάνω από 32 (`maxUniverseOffset`), γιατί στον πραγματικό κώδικα σπάνια
ξεπερνάμε το 2 ή το 3. Στις ασκήσεις χρησιμοποιούμε μεγάλα νούμερα μόνο ως σκέψη στο χαρτί.
:::

:::callout (kind := "deep") (title := "Impredicativity του Prop")
Γιατί το θέλουμε αυτό; Μια πρόταση της μορφής «για κάθε $`x : A`, ισχύει $`P\,x`» πρέπει να είναι
κι αυτή *πρόταση*, ακόμη κι αν το $`A` είναι τεράστιο universe. Αυτή η ιδιότητα λέγεται
_impredicativity_ του `Prop`. Χωρίς αυτήν, κάθε ποσοδείκτης θα «ανέβαζε» την πρόταση σε
ψηλότερο universe, και η λογική θα γινόταν πολύ δύσχρηστη. Θα το ξαναδούμε όταν φτάσουμε στις αποδείξεις.
:::

# Ερωτήσεις κατανόησης (2)

%%%
tag := "1-10-askiseis-2"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 2 — True ή Sort 0;")
Σε ποιο Sort ανήκουν τα `Sort 3 → Sort 5`, `Sort 100 → True` και `Nat → Sort 0`;

:::solution
*`Sort 6`, `Sort 0`, `Sort 1`.* Η απάντηση που δόθηκε ήταν _«6, 0, 0»_. Το τρίτο ήταν λάθος,
και ο μαθητής το εντόπισε αμέσως: _«Ξέχασα. Ο τύπος του Sort 0 είναι Sort 1»_.

* `Nat → True`: $`\mathsf{True} : \mathsf{Sort}\ 0`, άρα $`\mathrm{imax}(1,0) = 0`. Δέχεται αριθμό, επιστρέφει *απόδειξη* της `True`.
* `Nat → Sort 0`: $`\mathsf{Sort}\ 0 : \mathsf{Sort}\ 1`, άρα $`\mathrm{imax}(1,1) = 1`. Δέχεται αριθμό, επιστρέφει *πρόταση*.

Η πρώτη επιστρέφει αποδείξεις, η δεύτερη προτάσεις. Δεν είναι το ίδιο πράγμα.

```lean (name := natProp)
#check (Nat → Prop)
```
```leanOutput natProp
Nat → Prop : Type
```
:::
::::

:::::callout (kind := "exercise") (title := "Άσκηση 3 — Εμφωλευμένα βέλη")
Ποιος είναι ο τύπος του `Sort 3 → Sort 0`; Και ποιος του `Sort 2 → (Sort 3 → Sort 0)`;

::::solution
* Εσωτερικό: $`\mathsf{Sort}\ 3 : \mathsf{Sort}\ 4`, $`\mathsf{Sort}\ 0 : \mathsf{Sort}\ 1`, άρα $`\mathrm{imax}(4,1) = 4`, δηλαδή *`Sort 4`*. ✓
* Εξωτερικό: $`\mathsf{Sort}\ 2 : \mathsf{Sort}\ 3` και (εσωτερικό) $`: \mathsf{Sort}\ 4`, άρα $`\mathrm{imax}(3,4) = 4`, δηλαδή *`Sort 4`*.

Η απάντηση που δόθηκε (_«γκρρρ.. βιάστηκα»_) ήταν σωστή για το εσωτερικό, αλλά για το
εξωτερικό έδωσε `Sort 5`:
αντικατέστησε το codomain με τον τύπο του (`Sort 2 → Sort 4`) και ξαναϋπολόγισε τον τύπο
του `Sort 4`, κάνοντας έτσι ένα *επιπλέον +1*.

:::figure (src := "e01/arrow-recursion.svg") (caption := "Ο γονικός κόμβος χρησιμοποιεί τους τύπους που επέστρεψαν τα παιδιά του. Δεν ξανακαλεί το inferType πάνω τους.")
:::

```
inferType(forallE(A, B)):     -- μη εξαρτημένη περίπτωση
  sort(u) ← inferType(A)
  sort(v) ← inferType(B)
  return sort(imax(u, v))
```
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 4 — Μία ακόμη")
`(Sort 2 → Sort 3) → (Nat → Sort 0)`: βρες τον τύπο του αριστερού, του δεξιού και του εξωτερικού `forallE`.

:::solution
* Αριστερό: $`\mathrm{imax}(3,4) = 4`, άρα `Sort 4`.
* Δεξί: $`\mathrm{imax}(1,1) = 1`, άρα `Sort 1`.
* Εξωτερικό: $`\mathrm{imax}(4,1) = 4`, άρα *`Sort 4`*.

Σωστά και τα τρία (_«αφού ξέραμε τον τύπο, δεν κάναμε infer»_). Μια μικρή διόρθωση στη
σημειογραφία: η απάντηση γράφτηκε «type 4», αλλά το `Type 4` είναι το `Sort 5`. Το σωστό
είναι `Sort 4` (= `Type 3`).

```lean (name := last)
#check ((Sort 2 → Sort 3) → (Nat → Sort 0))
```
```leanOutput last
(Type 1 → Type 2) → Nat → Prop : Type 3
```
:::
::::

:::callout (kind := "summary")
* *Arrow rule:* αν $`A : \mathsf{Sort}\ u` και $`B : \mathsf{Sort}\ v`, τότε $`(A \to B) : \mathsf{Sort}\ (\mathrm{imax}(u,v))`.
* $`\mathrm{imax}(u,0) = 0`: συνάρτηση προς πρόταση είναι πρόταση (impredicativity).
* Τα $`u, v` είναι τα levels των *τύπων* του domain και του codomain, όχι αυτά που φαίνονται γραμμένα.
* Αναδρομή: ο γονικός κόμβος χρησιμοποιεί τα αποτελέσματα των παιδιών. Όχι διπλό βήμα.
:::
