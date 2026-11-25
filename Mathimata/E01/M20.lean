import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.20 — Η σχέση μεταξύ letE, lam και app" =>

%%%
tag := "m1-20"
file := "1-20"
number := false
%%%

:::callout (kind := "goals")
* Να δεις τη σχέση `let x := a; t` ↔ `(fun x => t) a`.
* Να γνωρίσεις τους κανόνες αναγωγής *β* και *ζ*.
* Να ξεχωρίζεις καθαρά το _typing_ από το _reduction_.
:::

# Ένα βήμα «προεκτέλεσης»;

%%%
tag := "1-20-intuition"
%%%

Μια φυσική εικόνα για το `let` είναι ότι «μεταφέρουμε την πληροφορία στο context, έτοιμη για
αντικατάσταση, σαν να έχουμε προεκτελέσει ένα βήμα της αποτίμησης».

Η διαίσθηση είναι πολύ κοντά. Μια διόρθωση όμως: στο `letE` *δεν* έχει εκτελεστεί κάποιο βήμα
αποτίμησης. Έχουμε φτιάξει μια τοπική δήλωση με τιμή, _διαθέσιμη_ για αντικατάσταση.

Σύγκρινε:

```lean
#check let x : Nat := 5; Nat.succ x
#check (fun (x : Nat) => Nat.succ x) 5
```

Και τα δύο έχουν τύπο `Nat` και καταλήγουν στο ίδιο αποτέλεσμα, αλλά είναι *διαφορετικά δέντρα*:

:::figure (src := "e01/let-vs-beta.svg") (caption := "Το letE συνδυάζει σε έναν κόμβο ό,τι το app+lam κάνει σε δύο: δέσμευση μεταβλητής, τιμή και body.")
:::

# β και ζ reduction

%%%
tag := "1-20-reduction"
%%%

Δύο κανόνες _αναγωγής_ (reduction), που χρησιμοποιούν και οι δύο τον μηχανισμό αντικατάστασης:

$$`(\lambda\, x : A.\ t)\ a \ \longrightarrow_\beta\ t[x := a] \qquad\qquad (\mathsf{let}\ x : A := a;\ t)\ \longrightarrow_\zeta\ t[x := a]`

```
let x : Nat := 5; Nat.succ x      ──ζ──▶   Nat.succ 5
(fun (x : Nat) => Nat.succ x) 5   ──β──▶   Nat.succ 5
```

Μπορούμε να ζητήσουμε από τη Lean να ελέγξει ότι τα δύο είναι ίσα *κατά ορισμό*:

```lean
example : (let x : Nat := 5; Nat.succ x) = Nat.succ 5 := rfl
example : (fun (x : Nat) => Nat.succ x) 5 = Nat.succ 5 := rfl
```

Το `rfl` πετυχαίνει επειδή ο kernel μπορεί να κάνει β και ζ αναγωγή όταν συγκρίνει.

# Typing και reduction: δύο διαφορετικές δουλειές

%%%
tag := "1-20-typing-vs-reduction"
%%%

:::table +header
*
  * Μηχανισμός
  * Σκοπός
  * Πού χρησιμοποιεί αντικατάσταση
*
  * Typing
  * βρίσκει/ελέγχει τον τύπο
  * στον *τύπο* του αποτελέσματος (Dependent App, 1.17)
*
  * Reduction
  * μετασχηματίζει την έκφραση
  * στο *body* της ίδιας της συνάρτησης (β)
:::

::::callout (kind := "exercise")
Για το `(fun (x : Nat) => Nat.succ x) 5`: τι επιστρέφει το `inferType`; Τι επιστρέφει ένα
βήμα β-reduction;

:::solution
*`Nat`* και *`Nat.succ 5`*.

Το πρώτο είναι *τύπος*, το δεύτερο είναι μια *έκφραση*, ισοδύναμη με την αρχική.
:::
::::

:::callout (kind := "deep") (title := "Πού βρισκόμαστε")
Μόλις είδαμε ότι η *αντικατάσταση* είναι η καρδιά και του typing (Dependent App) και του
reduction (β, ζ). Τα επόμενα μαθήματα, 1.21–1.25, εμβαθύνουν σε αυτήν: τι μπορεί να πάει
στραβά (variable capture) και πώς το λύνουν οι De Bruijn indices.
:::

:::callout (kind := "summary")
* Τα `let x := a; t` και `(fun x => t) a` έχουν το ίδιο αποτέλεσμα, αλλά διαφορετικά δέντρα.
* *β:* $`(\lambda x.\,t)\,a \to t[x:=a]`. *ζ:* $`(\mathsf{let}\ x := a;\ t) \to t[x:=a]`.
* Το typing βρίσκει τύπους, ενώ το reduction μετασχηματίζει εκφράσεις. Και τα δύο χρησιμοποιούν αντικατάσταση.
:::
