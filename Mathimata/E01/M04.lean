import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.4 — Το Context (Γ)" =>

%%%
tag := "m1-4"
file := "1-4"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τι είναι το τοπικό context $`\Gamma` και γιατί χρειάζεται.
* Να διαβάζεις και να εφαρμόζεις τον _Variable Rule_.
* Να ξεχωρίζεις το τοπικό context από το global environment.
:::

# Το πρόβλημα των μεταβλητών

%%%
tag := "1-4-problem"
%%%

Μέχρι τώρα γράφαμε judgments με κενό context, όπως το $`\vdash 5 : \mathsf{Nat}`. Τι γίνεται όμως
με ένα όνομα που η Lean δεν ξέρει;

```lean +error (name := unknownX)
#check x
```
```leanOutput unknownX (severity := Lean.MessageSeverity.error)
Unknown identifier `x`
```

Η Lean δεν έχει καμία πληροφορία για το `x`. Αν όμως _δηλώσουμε_ τον τύπο του:

```lean (name := withX)
section
variable (x : Nat)
#check x
end
```
```leanOutput withX
x : Nat
```

Δεν δώσαμε στο `x` καμία τιμή. Δηλώσαμε μόνο τον τύπο του, και αυτό αρκεί για να
ελεγχθούν οι τύποι. Η δήλωση `x : Nat` μπήκε στο *τοπικό context*.

# Η μαθηματική αναπαράσταση

%%%
tag := "1-4-math"
%%%

Το context είναι μια *διατεταγμένη ακολουθία* τοπικών δηλώσεων. Στο παράδειγμά μας
$`\Gamma = (x : \mathsf{Nat})`, και ο kernel μπορεί να τεκμηριώσει:

$$`x : \mathsf{Nat} \vdash x : \mathsf{Nat}`

Το `x : Nat` εμφανίζεται δύο φορές, με διαφορετικό ρόλο σε καθεμία:

:::table +header
*
  * Πλευρά του $`\vdash`
  * Ρόλος
*
  * Αριστερά
  * δήλωση που _έχουμε διαθέσιμη_ (υπόθεση)
*
  * Δεξιά
  * judgment που _πρέπει να τεκμηριωθεί_
:::

:::callout (kind := "tip") (title := "Μια οικεία αναλογία")
Στα μαθηματικά γράφουμε «Έστω $`x \in \mathbb{N}`. Τότε $`x + 0 = x`.» Το «έστω» είναι
ακριβώς το context: υποθέτουμε την ύπαρξη ενός $`x` με γνωστό τύπο, χωρίς να ξέρουμε
ποιο είναι. Το `variable` της Lean είναι το «έστω».
:::

# Ο Variable Rule

%%%
tag := "1-4-var-rule"
%%%

$$`\dfrac{(x : T) \in \Gamma}{\Gamma \vdash x : T}\ \textsf{(Var)}`

Διαβάζεται: _αν η μεταβλητή $`x` έχει δηλωθεί με τύπο $`T` στο (έγκυρο) context $`\Gamma`,
τότε μέσα σε αυτό το context το $`x` έχει τύπο $`T`._

Σε αντίθεση με τον κανόνα Sort, εδώ υπάρχει μια προϋπόθεση πάνω από τη γραμμή. Ο kernel
δεν χρειάζεται την _τιμή_ του `x`, μόνο τη _δήλωσή_ του.

# Context και environment

%%%
tag := "1-4-env"
%%%

Το context *δεν* είναι το ίδιο με το environment (που θα δούμε αναλυτικά στο 1.6):

:::table +header
*
  *
  * Environment
  * Τοπικό context
*
  * Περιέχει
  * καθολικές δηλώσεις
  * τοπικές υποθέσεις
*
  * Παραδείγματα
  * `Nat`, `Bool`, `True`
  * `x : Nat`, `y : Bool`
*
  * Διάρκεια
  * μόνιμο (για όλο το αρχείο)
  * μόνο μέσα στο `section` / τη συνάρτηση
:::

Ακόμη κι όταν το $`\Gamma` είναι κενό, ο kernel έχει πρόσβαση στο environment. Γι' αυτό
το $`\vdash \mathsf{Nat} : \mathsf{Sort}\ 1` δουλεύει χωρίς καμία δήλωση.

# Ερώτηση κατανόησης

%%%
tag := "1-4-askisi"
%%%

```lean (name := ctxAx)
section
variable (A : Sort 1)
variable (x : A)
#check A
#check x
end
```

::::callout (kind := "exercise")
Στο context $`\Gamma = (A : \mathsf{Sort}\ 1,\ x : A)`, ποια από τα παρακάτω μπορεί να τεκμηριώσει ο kernel;

1. $`\Gamma \vdash A : \mathsf{Sort}\ 1`
2. $`\Gamma \vdash x : A`
3. $`\Gamma \vdash x : \mathsf{Sort}\ 1`
4. $`\Gamma \vdash x : \mathsf{Nat}`

Και: χρειάζεται ο kernel να ξέρει _ποιος συγκεκριμένος τύπος_ είναι το $`A` για να
ελέγξει το $`x : A`;

:::solution
*Τα 1 και 2*, και τα δύο με τον Variable Rule. *Όχι*, δεν χρειάζεται να ξέρει τι είναι
το $`A`. Η δήλωση $`A : \mathsf{Sort}\ 1` αρκεί για να ξέρει ότι το $`A` είναι έγκυρος τύπος.
Η απάντηση που δόθηκε ήταν σωστή και στα δύο.

Το 3 είναι η γνωστή παγίδα της μεταβατικότητας: από $`x : A` και $`A : \mathsf{Sort}\ 1` *δεν*
προκύπτει $`x : \mathsf{Sort}\ 1`. Το 4 δεν προκύπτει από πουθενά, γιατί το $`A` δεν είναι ο `Nat`.
:::
::::

:::callout (kind := "note") (title := "Μια σημαντική παρατήρηση")
Η δήλωση `x : A` χρησιμοποιεί το `A`, που δηλώθηκε _πριν_. Στο context, οι μεταγενέστερες
δηλώσεις μπορούν να εξαρτώνται από τις προηγούμενες. Αυτό είναι το θέμα του επόμενου μαθήματος.
:::

:::callout (kind := "summary")
* Το context $`\Gamma` είναι μια διατεταγμένη λίστα τοπικών δηλώσεων ($`x : T`).
* *Variable Rule:* αν $`(x : T) \in \Gamma`, τότε $`\Gamma \vdash x : T`.
* Ο kernel χρειάζεται μόνο τον τύπο μιας μεταβλητής, όχι την τιμή της.
* Context (τοπικό) $`\neq` environment (καθολικό).
:::
