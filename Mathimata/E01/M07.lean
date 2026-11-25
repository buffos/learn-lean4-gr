import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.7 — Literal Rule" =>

%%%
tag := "m1-7"
file := "1-7"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις πώς αναπαρίστανται τα literals (`Expr.lit`) και ποιος είναι ο κανόνας τους.
* Να καταλάβεις γιατί το `(5 : Int)` δουλεύει, ενώ ο kernel δεν κάνει μετατροπές.
* Να βλέπεις ένα term ως *δέντρο* και να καταλάβεις ότι ο έλεγχος είναι *αναδρομικός*.
* Να γνωρίσεις την _partial application_: κάθε `Expr.app` παίρνει *ένα* όρισμα.
:::

# Η εσωτερική αναπαράσταση

%%%
tag := "1-7-repr"
%%%

```lean (name := litSig)
#check @Lean.Expr.lit
```
```leanOutput litSig
Lean.Expr.lit : Lean.Literal → Lean.Expr
```

Ο τύπος `Lean.Literal` έχει δύο constructors, άρα ο kernel ξέρει εγγενώς δύο είδη literals:

```lean (name := litCtors)
#print Lean.Literal
```

:::table +header
*
  * Literal
  * Τύπος που αποδίδει ο kernel
*
  * `Literal.natVal n`
  * `Nat`
*
  * `Literal.strVal s`
  * `String`
:::

```lean
open Lean in
def five  : Expr := .lit (.natVal 5)

open Lean in
def hello : Expr := .lit (.strVal "hello")
```

# Ο κανόνας

%%%
tag := "1-7-rule"
%%%

$$`\dfrac{}{\Sigma\,;\ \Gamma \vdash \mathsf{natLit}(n) : \mathsf{Nat}}\ \textsf{(NatLit)} \qquad \dfrac{}{\Sigma\,;\ \Gamma \vdash \mathsf{strLit}(s) : \mathsf{String}}\ \textsf{(StrLit)}`

Ο kernel δεν ψάχνει μια δήλωση με όνομα «5». Ξέρει από την κατασκευή `natVal` ότι
ο τύπος είναι `Nat`. (Οι κανόνες προϋποθέτουν ότι το environment περιέχει τους `Nat` και `String`.)

:::figure (src := "e01/four-rules.svg") (caption := "Οι τέσσερις κανόνες ως τώρα. Ο kernel διαλέγει κανόνα κοιτάζοντας την εξωτερική κατασκευή του Expr.")
:::

# Πώς γίνεται να δουλεύει το (5 : Int);

%%%
tag := "1-7-int"
%%%

```lean
#check (5 : Nat)
#check (5 : Int)
#check (5 : Float)
```

Και τα τρία είναι έγκυρα. Αφού ο κανόνας λέει ότι ένα literal έχει τύπο `Nat`, πώς γίνεται αυτό;

Το σύμβολο `5` στον κώδικα *δεν* γίνεται απαραίτητα ένα σκέτο `Expr.lit`. Ο *elaborator*
κοιτάζει τον αναμενόμενο τύπο και *κατασκευάζει ένα διαφορετικό term* που έχει τον σωστό
τύπο. Ο kernel, αντίθετα, δεν έχει καμία αμφισημία: το `Expr.lit (.natVal 5)` έχει τύπο
`Nat`, και τίποτε άλλο.

:::callout (kind := "tip") (title := "Ο elaborator κατασκευάζει, ο kernel ελέγχει")
Ο kernel *δεν κάνει αυτόματες μετατροπές*. Αν του δώσεις το `Expr.lit (.natVal 5)` και
του ζητήσεις να ελέγξει ότι έχει τύπο `Int`, θα το απορρίψει. Τη «μαγεία» του `(5 : Int)`
την κάνει ο elaborator, πριν φτάσει οτιδήποτε στον kernel.
:::

Δες τι πραγματικά κατασκευάζει ο elaborator, με την επιλογή `pp.all`:

```lean (name := ppAll)
set_option pp.all true in
#check (5 : Int)
```
```leanOutput ppAll
@OfNat.ofNat.{0} Int (nat_lit 5) (@instOfNat (nat_lit 5)) : Int
```

Το `nat_lit 5` είναι ακριβώς το «ωμό» `Expr.lit (.natVal 5)`, τύπου `Nat`. Ο elaborator
το τύλιξε μέσα σε μια κλήση της `OfNat.ofNat`, μαζί με ένα _instance_ (`instOfNat`) που
ξέρει πώς να φτιάξει ακέραιο από φυσικό. Το συνολικό term έχει τύπο `Int`. Τον μηχανισμό
`OfNat` θα τον δούμε αργότερα.

Κι ένα απλούστερο παράδειγμα της ίδιας ιδέας: η συνάρτηση `Int.ofNat : Nat → Int` παίρνει
έναν φυσικό και δίνει ακέραιο. Το `Int.ofNat 5` είναι ένα term τύπου `Int` που περιέχει
το literal `5` (τύπου `Nat`) ως _υποέκφραση_.

# Τα terms είναι δέντρα

%%%
tag := "1-7-trees"
%%%

Εσωτερικά, το `Int.ofNat 5` είναι:

```
Expr.app (Expr.const `Int.ofNat []) (Expr.lit (.natVal 5))
```

Εμφανίζεται μια νέα κατασκευή, το `Expr.app` (εφαρμογή συνάρτησης), που θα τη μελετήσουμε
στο 1.16. Ο kernel ελέγχει το δέντρο *αναδρομικά*, εφαρμόζοντας σε κάθε κόμβο τον
κανόνα της κατασκευής του:

:::table +header
*
  * Κόμβος
  * Κανόνας
  * Τύπος
*
  * `Expr.const Int.ofNat`
  * Const
  * `Nat → Int`
*
  * `Expr.lit 5`
  * Literal
  * `Nat`
*
  * `Expr.app` (όλο)
  * Application (1.16)
  * `Int`
:::

:::callout (kind := "mistake") (title := "«Αφού περιέχει literal, εφαρμόζεται ο Literal Rule»")
Θα εφαρμόσει ο kernel τον Literal Rule για τον τύπο _ολόκληρου_ του `Int.ofNat 5`, αφού
περιέχει literal; Η διαίσθηση λέει ναι, αλλά η απάντηση είναι *όχι*. Η εξωτερική κατασκευή είναι
`Expr.app`, οπότε εφαρμόζεται ο κανόνας της εφαρμογής. Ο Literal Rule εφαρμόζεται μόνο στην
υποέκφραση `5`, κατά τον αναδρομικό έλεγχο.
:::

# Partial application

%%%
tag := "1-7-partial"
%%%

```lean (name := appSig)
#check @Lean.Expr.app
```
```leanOutput appSig
Lean.Expr.app : Lean.Expr → Lean.Expr → Lean.Expr
```

Το `Expr.app` παίρνει *ακριβώς δύο* υποεκφράσεις: τη συνάρτηση και *ένα* όρισμα. Δεν
υπάρχει εφαρμογή με πολλά ορίσματα μαζί. Μια συνάρτηση δύο ορισμάτων εφαρμόζεται
_ένα όρισμα τη φορά_:

:::figure (src := "e01/expr-trees.svg") (caption := "Αριστερά: Nat.succ (Nat.succ 5), με δύο εφαρμογές τη μία μέσα στην άλλη. Δεξιά: Nat.add 5 6, όπου πρώτα σχηματίζεται το (Nat.add 5) και αυτό εφαρμόζεται στο 6.")
:::

```lean (name := partial)
#check Nat.add 5
#check (Nat.add 5) 6
```
```leanOutput partial
Nat.add 5 : Nat → Nat
```

Το `Nat.add 5` είναι από μόνο του ένα έγκυρο term: μια συνάρτηση που περιμένει άλλον έναν αριθμό.

# Ερωτήσεις κατανόησης

%%%
tag := "1-7-askiseis"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 1 — Θα δεχτεί ο kernel το literal ως Int;")
Ο kernel λαμβάνει απευθείας το `Expr.lit (.natVal 5)` και του ζητείται να ελέγξει ότι έχει
τύπο `Int`. Θα το δεχτεί;

:::solution
*Όχι.* Ο Literal Rule δίνει `Nat`, και ο kernel δεν μετατρέπει.

Μια συνηθισμένη εικόνα είναι ότι «εξωτερικά είναι ακέραιος, αλλά εσωτερικά έχει
αναπαράσταση Nat». Είναι κοντά, αλλά πρέπει να ξεχωρίσουμε δύο πράγματα:
την αναπαράσταση μιας _τιμής_ και την αναπαράσταση ενός _term_. Ο elaborator δεν φτιάχνει
ένα «literal που είναι ακέραιος». Φτιάχνει ένα *άλλο, μεγαλύτερο term* (π.χ. με `OfNat.ofNat`
ή `Int.ofNat`) που έχει τύπο `Int` και περιέχει το literal ως κομμάτι του.
:::
::::

:::::callout (kind := "exercise") (title := "Άσκηση 2 — Μέτρησε τους κόμβους")
Πόσους κόμβους `Expr.app`, `Expr.const` και `Expr.lit` έχει το `Nat.succ (Nat.succ 5)`;

::::solution
*2 `app`, 2 `const`, 1 `lit`* (5 κόμβοι συνολικά, δες το σχήμα παραπάνω).

Συχνό λάθος είναι να μετρηθεί ένα μόνο `app`. Κάθε εφαρμογή όμως είναι ξεχωριστός κόμβος.

```lean
open Lean in
def e : Expr :=
  .app (.const `Nat.succ [])
    (.app (.const `Nat.succ []) (.lit (.natVal 5)))
```

Το `Nat.succ 5` *δεν* γίνεται `6` στο δέντρο. Το δέντρο είναι η δομή *πριν* από κάθε υπολογισμό (_reduction_):

:::table +header
*
  * Διαδικασία
  * Ερώτημα
*
  * Κατασκευή
  * Ποια είναι η δομή του term;
*
  * Type checking
  * Ποιος είναι ο τύπος του, και είναι έγκυρο;
*
  * Reduction
  * Σε τι υπολογίζεται;
:::

Ο kernel βρίσκει ότι το `Nat.succ (Nat.succ 5)` έχει τύπο `Nat` *χωρίς* να υπολογίσει ότι είναι 7.
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 3 — Συνάρτηση δύο ορισμάτων")
Πώς αναπαρίσταται το `Nat.add 5 6`, αφού το `Expr.app` παίρνει ένα μόνο όρισμα;

:::solution
Το `Nat.add 5` είναι από μόνο του μια συνάρτηση (μερική εφαρμογή), και το `6` είναι το όρισμα
του δεύτερου `app`:

```
app (app (const Nat.add) (lit 5)) (lit 6)
```

2 `app`, 1 `const`, 2 `lit`. Αυτή είναι η _partial application_, και οδηγεί κατευθείαν
στο επόμενο μάθημα: τι τύπο έχει το `Nat.add`;
:::
::::

:::callout (kind := "summary")
* *Literal Rule:* `natLit n : Nat`, `strLit s : String`.
* Ο kernel δεν μετατρέπει τύπους. Το `(5 : Int)` το χειρίζεται ο elaborator, φτιάχνοντας άλλο term.
* Τα terms είναι δέντρα, και ο έλεγχος γίνεται αναδρομικά, με έναν κανόνα ανά κόμβο.
* Το `Expr.app` έχει ένα όρισμα. Οι συναρτήσεις πολλών ορισμάτων εφαρμόζονται ένα-ένα.
:::
