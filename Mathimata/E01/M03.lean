import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.3 — Sorts και Universes" =>

%%%
tag := "m1-3"
file := "1-3"
number := false
%%%

:::callout (kind := "goals")
* Να διαβάζεις έναν _typing rule_ (κανόνα τύπων) με την οριζόντια γραμμή.
* Να ξέρεις τον κανόνα των Sorts: $`\mathsf{Sort}\ u : \mathsf{Sort}\ (u+1)`.
* Να καταλάβεις ότι η _κατασκευή_ του term (αριστερή πλευρά) αποφασίζει ποιος κανόνας εφαρμόζεται.
* Να ξεχωρίζεις το `Prop` (`Sort 0`) από τους τύπους δεδομένων.
:::

# Ο πρώτος typing rule

%%%
tag := "1-3-rule"
%%%

Τα `Nat` και `Bool` είναι τύποι που _ορίστηκαν_ μέσα στη Lean. Το `Sort`, αντίθετα,
είναι *πρωτογενής κατασκευή του kernel*: δεν ορίζεται από κάτι άλλο. Ο kernel ξέρει
εγγενώς έναν κανόνα γι' αυτό:

$$`\dfrac{}{\ \Gamma \vdash \mathsf{Sort}\ u : \mathsf{Sort}\ (u+1)\ }\ \textsf{(Sort)}`

Έτσι γράφονται οι κανόνες στη θεωρία τύπων:

* *Πάνω* από τη γραμμή: οι _προϋποθέσεις_ (premises). Τι πρέπει να ισχύει ήδη.
* *Κάτω* από τη γραμμή: το _συμπέρασμα_ (conclusion). Τι μπορούμε τότε να συμπεράνουμε.

Εδώ δεν υπάρχουν προϋποθέσεις. Ο κανόνας ισχύει πάντα, για οποιοδήποτε universe level $`u`
(σε έγκυρο context, κάτι που θα δούμε στο 1.5).

```lean (name := sorts)
#check Sort 0
#check Sort 1
#check Sort 2
#check Sort 3
```

Η Lean εμφανίζει τα αποτελέσματα με συντομογραφίες: `Sort 0` είναι το `Prop` και
`Sort (u+1)` είναι το `Type u`:

```lean (name := sort2)
#check Sort 2
```
```leanOutput sort2
Type 1 : Type 2
```

:::table +header
*
  * Γράφουμε
  * Ισοδύναμο
  * Τι περιέχει
*
  * `Sort 0`
  * `Prop`
  * λογικές προτάσεις
*
  * `Sort 1`
  * `Type` (= `Type 0`)
  * τύπους δεδομένων, π.χ. `Nat`, `Bool`
*
  * `Sort 2`
  * `Type 1`
  * π.χ. το ίδιο το `Type`
:::

# Term και universe level: δύο διαφορετικά πράγματα

%%%
tag := "1-3-level"
%%%

Εσωτερικά, το `Sort` αναπαρίσταται με την κατασκευή `Expr.sort`:

```lean (name := exprSort)
#check @Lean.Expr.sort
```
```leanOutput exprSort
Lean.Expr.sort : Lean.Level → Lean.Expr
```

Δηλαδή χρειάζεται ένα `Lean.Level` και δίνει ένα `Lean.Expr`. Εμφανίζεται έτσι μια νέα διάκριση:

:::table +header
*
  * Έννοια
  * Εσωτερική αναπαράσταση
  * Παράδειγμα
*
  * Term
  * `Lean.Expr`
  * `Sort 2`, `Nat`, `5`
*
  * Universe level
  * `Lean.Level`
  * το `2` μέσα στο `Sort 2`
:::

:::callout (kind := "mistake") (title := "Το 2 στο Sort 2 δεν είναι Nat")
Το `Sort 2` *δεν* είναι μια συνάρτηση `Sort` εφαρμοσμένη στον φυσικό αριθμό `2`.
Το `2` εδώ είναι _universe level_, μια παράμετρος της πρωτογενούς κατασκευής, από
ξεχωριστή «γλώσσα» επιπέδων. Γι' αυτό δεν μπορείς να γράψεις π.χ. `Sort (1 + 1 : Nat)`.
:::

# Ποιος κανόνας εφαρμόζεται;

%%%
tag := "1-3-which-rule"
%%%

Ο κανόνας των Sorts θυμίζει την ιδέα `ord(type) + 1` από το μάθημα 1.2. Δεν εφαρμόζεται
όμως σε _κάθε_ term. Ο kernel κοιτάζει *ποια κατασκευή* είναι το term και διαλέγει
τον αντίστοιχο κανόνα:

:::table +header
*
  * Term
  * Κατασκευή
  * Κανόνας
  * Τύπος
*
  * `5`
  * `Expr.lit`
  * Literal rule (1.7)
  * `Nat`
*
  * `Nat`
  * `Expr.const`
  * Constant rule (1.6): ψάχνει τη δήλωση στο environment
  * `Sort 1`
*
  * `Sort 1`
  * `Expr.sort`
  * Sort rule, με $`u = 1`
  * `Sort 2`
:::

:::callout (kind := "tip") (title := "Κλειδί για όλη την ενότητα")
Η *αριστερή πλευρά* του judgment (η μορφή του term) καθορίζει τον κανόνα. Ο `Nat` και
το `Sort 0` έχουν τον _ίδιο_ τύπο (`Sort 1`), αλλά ο kernel τον βρίσκει με
_διαφορετικό_ κανόνα: για τον `Nat` κοιτάζει στο environment, για το `Sort 0` εφαρμόζει τον κανόνα Sort.
Σε κάθε μάθημα που ακολουθεί θα προσθέτουμε έναν κανόνα για μια νέα κατασκευή του `Expr`.
:::

# Η ιεραρχία, πληρέστερα

%%%
tag := "1-3-hierarchy"
%%%

```lean (name := props)
#check True
#check False
```
```leanOutput props
True : Prop
```

:::figure (src := "e01/universes.svg") (caption := "Η ιεραρχία των universes. Κάθε βέλος σημαίνει «έχει τύπο». Τα True/False είναι λογικές προτάσεις, ενώ τα Nat/Bool είναι τύποι δεδομένων.")
:::

Τα Sorts _δεν_ είναι μια αρίθμηση όλων των terms. Είναι συγκεκριμένα terms που
σχηματίζουν μια άπειρη σκάλα. Το `5` δεν έχει τύπο κάποιο Sort· έχει τύπο `Nat`.

# Ερωτήσεις κατανόησης

%%%
tag := "1-3-askiseis"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 1 — Πού εφαρμόζεται ο κανόνας Sort;")
Για ποια από τα $`\vdash 5 : \mathsf{Nat}`, $`\vdash \mathsf{Nat} : \mathsf{Sort}\ 1`,
$`\vdash \mathsf{Sort}\ 1 : \mathsf{Sort}\ 2` μπορεί ο kernel να χρησιμοποιήσει
_απευθείας_ τον κανόνα Sort;

:::solution
*Μόνο για το τρίτο.* Είναι το μόνο term που είναι κατασκευή `Expr.sort`.

Συχνή απορία: «μήπως το `5` είναι `Sort 0`;». Όχι. Το `5` *δεν* είναι `Sort 0` ούτε κανένα Sort, και ο τύπος του δεν είναι Sort: είναι
`Nat`. Και για το δεύτερο, παρόλο που ο _τύπος_ του `Nat` είναι Sort, το ίδιο το `Nat`
είναι σταθερά, οπότε εφαρμόζεται ο constant rule.
:::
::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Ποια πλευρά αποφασίζει;")
Τα judgments $`\vdash \mathsf{Nat} : \mathsf{Sort}\ 1` και $`\vdash \mathsf{Sort}\ 0 : \mathsf{Sort}\ 1`
έχουν τον ίδιο τύπο. Γιατί ο kernel χρησιμοποιεί διαφορετικό κανόνα; Ποια πλευρά του
judgment το καθορίζει;

:::solution
*Η αριστερή:* η κατασκευή του term (`Expr.const` ή `Expr.sort`) αποφασίζει τον κανόνα.
:::
::::

:::callout (kind := "mistake") (title := "«Το Sort (u+1) είναι το δυναμοσύνολο του Sort u;»")
Όποιος έρχεται από τη θεωρία συνόλων μπορεί να σκεφτεί έτσι: αν
$`\mathsf{Sort}\ 1 = \mathcal{P}(\mathsf{Sort}\ 0)` και $`\mathsf{Nat} \in \mathsf{Sort}\ 1`,
τότε $`\mathsf{Nat} \subseteq \mathsf{Sort}\ 0`, άρα και το `5` θα έπρεπε να ανήκει στο `Sort 0`.

Ο συλλογισμός είναι συνεπής, αλλά η _αρχική υπόθεση_ είναι λάθος. Τα universes *δεν* είναι
δυναμοσύνολα. Ο μόνος κανόνας είναι $`\mathsf{Sort}\ u : \mathsf{Sort}\ (u+1)`, και δεν λέει
τίποτα για υποσύνολα.

Καλύτερη αναλογία: ένα universe είναι μια _συλλογή_ συνόλων, π.χ. $`U = \{\mathbb{N}, \mathbb{Z}, \mathbb{R}\}`.
Ισχύει $`5 \in \mathbb{N}` και $`\mathbb{N} \in U`, αλλά *όχι* $`5 \in U`. Η σχέση «ανήκει»
δεν είναι μεταβατική, όπως ακριβώς και η σχέση «έχει τύπο».
:::

::::callout (kind := "exercise") (title := "Άσκηση 3 — True ή Bool.true ως τύπος;")
Ξέρουμε ότι `Bool.true : Bool` και `True : Prop`. Μπορεί το `True` να χρησιμοποιηθεί
ως τύπος κάποιου άλλου term; Μπορεί το `Bool.true`;

:::solution
Το `True` *ναι*, το `Bool.true` *όχι*. Προσοχή στη διατύπωση: το «το `True` είναι της μορφής
Sort» δεν είναι ακριβές. Το ίδιο το `True`
δεν είναι Sort· ο *τύπος* του είναι Sort (`Sort 0`). Αυτό ακριβώς ζητά ο κανόνας
εγκυρότητας τύπου του 1.2.

```lean (name := trueType)
#check (trivial : True)
```
```leanOutput trueType
trivial : True
```

Το `trivial` είναι ένα term με τύπο `True`, δηλαδή μια _απόδειξη_ της πρότασης `True`.
Με αυτή την ιδέα θα ασχοληθούμε αργότερα: *προτάσεις ως τύποι, αποδείξεις ως terms*.
:::
::::

:::callout (kind := "summary")
* Ο κανόνας Sort, $`\Gamma \vdash \mathsf{Sort}\ u : \mathsf{Sort}\ (u+1)`, είναι πρωτογενής και δεν έχει προϋποθέσεις.
* `Prop` = `Sort 0`, `Type u` = `Sort (u+1)`.
* Το `u` είναι `Lean.Level`, όχι term.
* Ο kernel διαλέγει κανόνα ανάλογα με την *κατασκευή* του term.
* Τα universes είναι συλλογές, όχι δυναμοσύνολα· η σχέση «έχει τύπο» δεν είναι μεταβατική.
:::
