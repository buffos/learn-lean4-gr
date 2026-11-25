import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.2 — Οι τύποι είναι επίσης terms" =>

%%%
tag := "m1-2"
file := "1-2"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις ότι στη Lean οι τύποι είναι κι αυτοί terms, με δικό τους τύπο.
* Να ξέρεις πότε ένα term μπορεί να χρησιμοποιηθεί _ως τύπος_ (πρέπει να έχει τύπο ένα `Sort`).
* Να ξεχωρίζεις τα σφάλματα *invalid type* και *type mismatch*.
:::

# Ποιος είναι ο τύπος ενός τύπου;

%%%
tag := "1-2-typos-typou"
%%%

Σε πολλές γλώσσες προγραμματισμού (Java, C, Python) υπάρχουν δύο ξεχωριστοί
κόσμοι: οι _τιμές_ (`7`, `"abc"`) και οι _τύποι_ (`int`, `String`). Στη Lean
αυτό δεν ισχύει: *οι τύποι είναι κι αυτοί terms*.

Ξέρουμε ότι `7 : Nat`. Τι γίνεται αν ρωτήσουμε για το ίδιο το `Nat`;

```lean (name := checkNat)
#check Nat
```
```leanOutput checkNat
Nat : Type
```

Έχουμε λοιπόν δύο έγκυρα judgments:

$$`\vdash 7 : \mathsf{Nat} \qquad\qquad \vdash \mathsf{Nat} : \mathsf{Type}`

Το `Nat` εμφανίζεται με *διαφορετικό ρόλο* σε καθένα. Στο πρώτο είναι δεξιά της
άνω και κάτω τελείας, ως _τύπος_ του `7`. Στο δεύτερο είναι αριστερά, ως _term_
του οποίου ελέγχουμε τον τύπο.

# Μία γλώσσα για όλα: `Lean.Expr`

%%%
tag := "1-2-lean-expr"
%%%

Στο εσωτερικό της Lean υπάρχει ένας τύπος δεδομένων, ο `Lean.Expr`, που
αναπαριστά _όλες_ τις εκφράσεις, είτε είναι τιμές είτε τύποι:

:::table +header
*
  * Έκφραση
  * Εσωτερική κατασκευή
  * Τι είναι
*
  * `7`
  * `Expr.lit`
  * literal
*
  * `Nat`
  * `Expr.const`
  * σταθερά (όνομα από το environment)
*
  * `Type`
  * `Expr.sort`
  * sort (θα το δούμε στο 1.3)
:::

Ο kernel *δεν* έχει ξεχωριστή γλώσσα για τις τιμές και άλλη για τους τύπους.

:::callout (kind := "deep") (title := "Δες το με τα μάτια σου")
Μπορούμε να ζητήσουμε από τη Lean να μας δείξει την εσωτερική μορφή μιας έκφρασης:

```lean (name := exprs)
open Lean in
#eval show MetaM Unit from do
  IO.println (repr (← Meta.mkConstWithFreshMVarLevels ``Nat))
```
```leanOutput exprs
Lean.Expr.const `Nat []
```
:::

# Η ιεραρχία που σχηματίζεται

%%%
tag := "1-2-ierarchia"
%%%

:::figure (src := "e01/typing-tree.svg") (caption := "Τιμές, τύποι και τύποι τύπων. Κάθε βέλος είναι ένα typing judgment.")
:::

:::callout (kind := "mistake") (title := "Δεν είναι κληρονομικότητα")
Αν έρχεσαι από αντικειμενοστραφή προγραμματισμό, μην διαβάσεις τα βέλη ως «το `Nat`
είναι υποκλάση του `Type`». Κάθε βέλος σημαίνει μόνο ένα πράγμα: *«έχει τύπο»*.
Ούτε μετατροπή δεδομένων είναι.
:::

# Ερωτήσεις κατανόησης (1)

%%%
tag := "1-2-askiseis-1"
%%%

Δίνονται:

```lean (name := checkBool)
#check Bool
#check Bool.true
```

με απαντήσεις `Bool : Type` και `Bool.true : Bool`.

:::::callout (kind := "exercise") (title := "Άσκηση 1 — Πόσα terms;")
Πόσα διαφορετικά terms εμφανίζονται συνολικά στα judgments
$`\vdash \mathsf{Bool.true} : \mathsf{Bool}` και $`\vdash \mathsf{Bool} : \mathsf{Type}`;

::::solution
*Τρία:* `Bool.true`, `Bool` και `Type`.

Η πρώτη απάντηση ήταν _«ένα, το `Bool.true`»_, και αυτή είναι η πιο συνηθισμένη
παρανόηση στην αρχή. Η διόρθωση:

:::table +header
*
  * Έκφραση
  * Είναι term;
  * Είναι τύπος;
*
  * `Bool.true`
  * Ναι
  * Όχι
*
  * `Bool`
  * Ναι
  * Ναι
*
  * `Type`
  * Ναι
  * Ναι
:::

Το *term* είναι η γενικότερη έννοια. Το ότι κάτι είναι τύπος _δεν αποκλείει_
να είναι και term. Ορισμένα terms μπορούν επιπλέον να χρησιμοποιηθούν ως τύποι.
::::
:::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Ίδιος τύπος;")
Αφού και το `Bool` και το `Nat` έχουν τύπο `Type`, σημαίνει αυτό ότι είναι ο ίδιος τύπος;

:::solution
*Όχι.* Είναι δύο διαφορετικά terms που _έχουν τον ίδιο τύπο_, όπως ακριβώς τα `5`
και `6` είναι διαφορετικοί αριθμοί που έχουν και οι δύο τύπο `Nat`:

$$`\vdash 5 : \mathsf{Nat},\ \vdash 6 : \mathsf{Nat} \qquad\text{αντίστοιχα}\qquad \vdash \mathsf{Bool} : \mathsf{Type},\ \vdash \mathsf{Nat} : \mathsf{Type}`

Η απάντηση που δόθηκε χρησιμοποίησε ακριβώς αυτή την αναλογία, και είναι εύστοχη.
Πρότεινε επίσης να τα δούμε ως «ίδια» ως προς μια _κλάση ισοδυναμίας_ («έχει τον ίδιο τύπο»).
Αυτή η σχέση μπορεί να οριστεί, αλλά *δεν* συνεπάγεται ισότητα των ίδιων των terms.
Το να έχουν δύο terms κοινό τύπο και το να είναι ίσα είναι διαφορετικές έννοιες.
:::
::::

::::callout (kind := "exercise") (title := "Άσκηση 3 — Ο τύπος του Type")
Τι πιστεύεις ότι θα απαντήσει η Lean στο `#check Type`;

:::solution
Η απάντηση ήταν _«το επόμενο στην ιεραρχία, `Type 1`»_. Σωστά:

```lean (name := checkType)
#check Type
```
```leanOutput checkType
Type : Type 1
```

Αν ίσχυε `Type : Type`, θα προέκυπτε λογική αντίφαση (το _παράδοξο του Girard_).
Γι' αυτό υπάρχει μια άπειρη ιεραρχία. Τη μελετάμε στο μάθημα 1.3.
:::
::::

# Πότε ένα term μπορεί να είναι τύπος;

%%%
tag := "1-2-term-os-typos"
%%%

Στο judgment $`\Gamma \vdash t : T`, *και* το $`t` *και* το $`T` είναι terms.
Όμως δεν μπορεί _οποιοδήποτε_ term να μπει στη θέση του $`T`. Δες:

```lean
#check (5 : Nat)
#check (Nat : Type)
```

Αυτά είναι έγκυρα. Το `(5 : 6)` όμως απορρίπτεται, παρόλο που και το `5` και το `6`
είναι έγκυρα terms. Για να δούμε καθαρά _γιατί_, κλειδώνουμε πρώτα ότι το `6` είναι `Nat`:

```lean +error (name := fiveSix)
#check (5 : (6 : Nat))
```
```leanOutput fiveSix (severity := Lean.MessageSeverity.error)
type expected, got
  (6 : Nat)
```

Η Lean λέει: _περίμενα τύπο, και πήρα το `6`, που έχει τύπο `Nat`_.

:::callout (kind := "deep") (title := "Τι γίνεται με σκέτο (5 : 6);")
Αν γράψουμε σκέτο `(5 : 6)`, το μήνυμα είναι διαφορετικό, και δείχνει πόσο
«εξυπηρετικός» είναι ο elaborator. Επειδή τα literals είναι πολυμορφικά, ψάχνει
μήπως το `6` μπορεί να ερμηνευτεί _ως τύπος_, δηλαδή μήπως υπάρχει
instance `OfNat (Sort u) 6`:

```lean +error (name := fiveSixRaw)
#check (5 : 6)
```
```leanOutput fiveSixRaw (severity := Lean.MessageSeverity.error)
failed to synthesize instance of type class
  OfNat (Sort ?u.1) 6
numerals are polymorphic in Lean, but the numeral `6` cannot be used in a context where the expected type is
  Sort ?u.1
due to the absence of the instance above

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

Η αιτία είναι ίδια (δεν υπάρχει τρόπος το `6` να είναι `Sort`). Αλλάζει μόνο το
σημείο του elaborator όπου εντοπίζεται.
:::

:::callout (kind := "mistake") (title := "Μια λανθασμένη πρώτη ιδέα")
Η πρώτη απάντηση στο _γιατί_ ήταν: _«ο τύπος δεξιά πρέπει να είναι `ord(type) + 1`»_,
δηλαδή κάθε term να έχει ένα «επίπεδο» και ο τύπος να είναι ένα επίπεδο πάνω.
Η κατεύθυνση (σύνδεση με την ιεραρχία) είναι καλή, αλλά ο kernel *δεν* αναθέτει
αριθμό επιπέδου σε κάθε term. Ο κανόνας είναι πιο συγκεκριμένος.
:::

Ο κανόνας είναι ο εξής: για να είναι το $`T` έγκυρος τύπος, πρέπει *το ίδιο το $`T` να έχει
ως τύπο κάποιο `Sort`*:

$$`\Gamma \vdash T : \mathsf{Sort}\ u`

όπου $`u` είναι ένα _universe level_. Προς το παρόν αρκεί να ξέρουμε ότι
`Type` είναι συντομογραφία του `Sort 1`:

```lean (name := typeSort)
#check (Nat : Sort 1)
```
```leanOutput typeSort
Nat : Type
```

:::table +header
*
  * Term
  * Ο τύπος του
  * Μπορεί να χρησιμοποιηθεί ως τύπος;
*
  * `5`, `6`
  * `Nat`
  * Όχι, γιατί ο `Nat` δεν είναι `Sort`
*
  * `Nat`, `Bool`
  * `Sort 1`
  * Ναι
*
  * `Sort 1`
  * `Sort 2`
  * Ναι
:::

# Δύο διαφορετικά σφάλματα

%%%
tag := "1-2-sfalmata"
%%%

Για να ελεγχθεί το $`t : T`, πρέπει να απαντηθούν τρία ερωτήματα:

:::figure (src := "e01/check-steps.svg") (caption := "Οι τρεις λογικές προϋποθέσεις, και πού αποτυγχάνει κάθε παράδειγμα.")
:::

* *Invalid type*: το `(5 : 6)` αποτυγχάνει στο ①. Το `6` έχει τύπο `Nat`, και ο
  `Nat` δεν είναι `Sort`.
* *Type mismatch*: το `((5 : Nat) : Bool)` περνάει το ① (ο `Bool` είναι τύπος),
  αλλά αποτυγχάνει στο ③, γιατί ο `Nat` δεν είναι _definitionally equal_ με τον `Bool`.

```lean +error (name := mismatch)
#check ((5 : Nat) : Bool)
```
```leanOutput mismatch (severity := Lean.MessageSeverity.error)
Type mismatch
  5
has type
  Nat
but is expected to have type
  Bool
```

:::callout (kind := "note") (title := "Γιατί όχι απλώς (5 : Bool);")
Τα αριθμητικά literals είναι _υπερφορτωμένα_. Στο `(5 : Bool)` ο elaborator
προσπαθεί να κατασκευάσει το `5` _απευθείας_ ως `Bool`, μέσω της κλάσης
`OfNat`, και αποτυγχάνει με διαφορετικό μήνυμα:

```lean +error (name := ofNatBool)
#check (5 : Bool)
```
```leanOutput ofNatBool (severity := Lean.MessageSeverity.error)
failed to synthesize instance of type class
  OfNat Bool 5
numerals are polymorphic in Lean, but the numeral `5` cannot be used in a context where the expected type is
  Bool
due to the absence of the instance above

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
```

Με το `(5 : Nat)` «κλειδώνουμε» πρώτα τον τύπο του `5`, ώστε να δούμε καθαρό type mismatch.
:::

:::callout (kind := "mistake") (title := "«Είναι syntax error;»")
Για το `(5 : 6)` δόθηκε η απάντηση _«είναι σαν syntax error, δεν μπαίνουμε καν στο
type checking»_. *Όχι.* Συντακτικά η έκφραση είναι άψογη: ο parser βλέπει
`(term : term)`. Για να διαπιστωθεί ότι το `6` δεν είναι τύπος, πρέπει πρώτα να
_βρεθεί ο τύπος του_ (`Nat`). Αυτό είναι ήδη type checking.
:::

:::callout (kind := "note")
Τα τρία ερωτήματα περιγράφουν τις _λογικές προϋποθέσεις_, όχι απαραίτητα την ακριβή
σειρά εκτέλεσης στον kernel. Στα παραδείγματα αυτά, μάλιστα, τα σφάλματα τα
βρίσκει ήδη ο elaborator, πριν φτάσει οτιδήποτε στον kernel.
:::

# Ερωτήσεις κατανόησης (2)

%%%
tag := "1-2-askiseis-2"
%%%

:::::callout (kind := "exercise") (title := "Άσκηση 4 — Έγκυρο ή όχι;")
Ποια από τα παρακάτω είναι έγκυρα; Για όσα απορρίπτονται, είναι *invalid type*
ή *type mismatch*;

1. `#check (Nat : Sort 1)`
2. `#check (Nat : Sort 2)`
3. `#check (Sort 1 : Sort 2)`
4. `#check (Sort 1 : Nat)`

::::solution
Η απάντηση που δόθηκε, _«έγκυρα 1, 3· type mismatch 2, 4»_, είναι *πλήρως σωστή*.

:::table +header
*
  * Έκφραση
  * Αποτέλεσμα
  * Αιτιολογία
*
  * `(Nat : Sort 1)`
  * ✓ Έγκυρη
  * Ο τύπος του `Nat` είναι `Sort 1`.
*
  * `(Nat : Sort 2)`
  * ✗ Type mismatch
  * Ο τύπος του `Nat` είναι `Sort 1`, όχι `Sort 2`.
*
  * `(Sort 1 : Sort 2)`
  * ✓ Έγκυρη
  * Ο τύπος του `Sort 1` είναι `Sort 2`.
*
  * `(Sort 1 : Nat)`
  * ✗ Type mismatch
  * Ο τύπος του `Sort 1` είναι `Sort 2`, όχι `Nat`.
:::

Σε όλες τις περιπτώσεις, η έκφραση δεξιά του `:` _είναι_ έγκυρος τύπος, οπότε
κανένα δεν είναι invalid type.

```lean +error (name := sort2)
#check (Nat : Sort 2)
```
```leanOutput sort2 (severity := Lean.MessageSeverity.error)
Type mismatch
  Nat
has type
  Type
of sort `Type 1` but is expected to have type
  Type 1
of sort `Type 2`
```
::::
:::::

:::callout (kind := "deep") (title := "Η Lean δεν είναι cumulative")
Η περίπτωση 2 αξίζει προσοχή: η Lean *δεν* δέχεται αυτόματα κάτι από το `Sort 1`
εκεί που περιμένει `Sort 2`, παρόλο που το `Sort 2` είναι «ψηλότερα». Άλλα
συστήματα (π.χ. Coq/Rocq) έχουν _cumulativity_ και θα το δέχονταν. Στη Lean, για
να ανεβάσεις έναν τύπο universe χρειάζεσαι ρητά το `ULift`.
:::

:::callout (kind := "summary")
* Οι τύποι είναι terms: `Nat : Type`, `Type : Type 1`.
* Όλα αναπαριστώνται εσωτερικά ως `Lean.Expr`.
* Ένα term $`T` μπορεί να χρησιμοποιηθεί ως τύπος μόνο αν $`\Gamma \vdash T : \mathsf{Sort}\ u`.
* *Invalid type*: αυτό που μπήκε δεξιά του `:` δεν είναι τύπος. *Type mismatch*: είναι τύπος, αλλά όχι ο σωστός.
:::
