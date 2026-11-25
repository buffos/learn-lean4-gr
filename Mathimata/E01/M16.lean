import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.16 — Application Typing Rule" =>

%%%
tag := "m1-16"
file := "1-16"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τον κανόνα _App_ για μη εξαρτημένες συναρτήσεις.
* Να ξεχωρίζεις *καθαρά* τα `lam` (κατασκευάζει συνάρτηση) και `app` (χρησιμοποιεί συνάρτηση).
* Να σχεδιάζεις και να «διαβάζεις» δέντρα με `lam`, `app`, `bvar`.
* Να θυμάσαι ότι η εφαρμογή είναι αριστερά προσεταιριστική.
:::

# Ο κανόνας

%%%
tag := "1-16-rule"
%%%

Με $`\Gamma = (f : \mathsf{Nat} \to \mathsf{Bool},\ x : \mathsf{Nat})`, ο τύπος του `f x` βρίσκεται
ελέγχοντας τα δύο παιδιά, και ότι ο τύπος του ορίσματος ταιριάζει με το domain:

$$`\dfrac{\Gamma \vdash f : A \to B \qquad \Gamma \vdash a : A}{\Gamma \vdash f\ a : B}\ \textsf{(App)}`

```
inferType(app(f, a), Γ):
  forallE(x, A, B) ← inferType(f, Γ)
  T ← inferType(a, Γ)
  if not defEq(T, A): error "type mismatch"
  return B
```

Σε αντίθεση με τα `lam` και `forallE`, *το `app` δεν επεκτείνει το context*: δεν εισάγει binder.
(Το `defEq`, η _definitional equality_, είναι μηχανισμός που θα δούμε ξεχωριστά.)

# Ερώτηση κατανόησης (1)

%%%
tag := "1-16-askisi-1"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 1 — Σύνθεση")
Με `f : Nat → Bool`, `g : Bool → String`, `x : Nat`: βρες τον τύπο κάθε κόμβου του `g (f x)`.
Είναι έγκυρο το `f (g x)`;

:::solution
Σωστά σε όλα: `x : Nat`, `f : Nat → Bool`, `f x : Bool`, `g : Bool → String`, `g (f x) : String`.
Το `f (g x)` *αποτυγχάνει ήδη στο εσωτερικό* `g x`: η `g` θέλει `Bool`, και το `x` είναι `Nat`.

```lean +error (name := badComp)
section
variable (f : Nat → Bool) (g : Bool → String) (x : Nat)
#check f (g x)
end
```
```leanOutput badComp (severity := Lean.MessageSeverity.error)
Application type mismatch: The argument
  x
has type
  Nat
but is expected to have type
  Bool
in the application
  g x
```
:::
::::

# lam ή app; Η θεμελιώδης διαφορά

%%%
tag := "1-16-lam-vs-app"
%%%

Σε αυτό το σημείο, τα `app` και `lam` μπερδεύονται εύκολα. Αξίζει να σταθούμε εδώ.

:::table +header
*
  * Κατασκευή
  * Μαθηματικά
  * Lean
  * Τι κάνει
*
  * `forallE`
  * $`\mathbb{N} \to \mathbb{N}`
  * `Nat → Nat`
  * *περιγράφει* συναρτήσεις
*
  * `lam`
  * $`x \mapsto x`
  * `fun (x : Nat) => x`
  * *κατασκευάζει* μια συνάρτηση
*
  * `app`
  * $`f(5)`
  * `f 5`
  * *χρησιμοποιεί* μια συνάρτηση
:::

Η `lam` *δεν χρειάζεται συγκεκριμένη τιμή*: φτιάχνει τη συνάρτηση χωρίς να ξέρει τι θα πάρει
το `x`. Η `app` *δίνει όρισμα*. Μπορούν να συνυπάρχουν:

```lean (name := lamApp)
#check (fun (x : Nat) => x) 5
```
```leanOutput lamApp
(fun x => x) 5 : Nat
```

:::figure (src := "e01/app-lam.svg") (caption := "Η lam περιγράφει τη συνάρτηση, και η app την εφαρμόζει στο 5. Ο kernel βρίσκει τον τύπο Nat χωρίς να υπολογίσει ότι το αποτέλεσμα είναι 5.")
:::

:::table +header
*
  * Ιδιότητα
  * `forallE`
  * `lam`
  * `app`
*
  * Εισάγει binder
  * Ναι
  * Ναι
  * Όχι
*
  * Επεκτείνει το context
  * Ναι
  * Ναι
  * Όχι
*
  * Παίρνει συγκεκριμένο όρισμα
  * Όχι
  * Όχι
  * Ναι
*
  * Τύπος που προκύπτει
  * `Sort`
  * `forallE`
  * ό,τι λέει η συνάρτηση
:::

:::callout (kind := "tip") (title := "Μια αναλογία")
Η `lam` είναι σαν να *γράφεις* μια συνταγή («πάρε ένα αυγό και…»). Η `app` είναι σαν να την
*εκτελείς* με ένα συγκεκριμένο αυγό. Η `forallE` είναι η *κατηγορία* της συνταγής («από
αυγό σε ομελέτα»).
:::

# Ερωτήσεις κατανόησης (2)

%%%
tag := "1-16-askiseis-2"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 2 — app μέσα σε lam")
Σχεδίασε το δέντρο του `fun (x : Nat) => Nat.succ x`. Γιατί υπάρχει `app`, αφού δεν
δώσαμε ακόμη τιμή στο `x`;

:::solution
Το δέντρο είναι:

```
lam (x)                    : Nat → Nat
├── const Nat              : Sort 1
└── app                    : Nat
    ├── const Nat.succ     : Nat → Nat
    └── bvar 0             : Nat
```

Η έκφραση έχει *δύο* συναρτήσεις: αυτή που φτιάχνουμε (με `lam`) και την έτοιμη `Nat.succ`,
που την εφαρμόζουμε (με `app`). *Το όρισμα μιας `app` δεν χρειάζεται να είναι συγκεκριμένη
τιμή, αρκεί να έχει γνωστό τύπο.* Μέσα στο body ισχύει $`x : \mathsf{Nat}`, και αυτό φτάνει.
:::
::::

::::callout (kind := "exercise") (title := "Άσκηση 3 — Συνάρτηση ως όρισμα")
Σχεδίασε το δέντρο του `fun (f : Nat → Nat) => fun (x : Nat) => f x` και βρες τον τύπο του.
Πρόσεξε τους δείκτες των `f` και `x`.

:::solution
Με δείκτες `bvar 1` για το `f` και `bvar 0` για το `x`:

```
lam (f)                     : (Nat → Nat) → Nat → Nat
├── forallE (_)             : Sort 1
│   ├── const Nat
│   └── const Nat
└── lam (x)                 : Nat → Nat
    ├── const Nat
    └── app                 : Nat
        ├── bvar 1          : Nat → Nat     -- f
        └── bvar 0          : Nat           -- x
```

Ο binder του `forallE` (ο τύπος του `f`) *δεν* επηρεάζει τους δείκτες μέσα στην `app`,
γιατί βρίσκεται σε άλλο κλαδί του δέντρου, εκτός του scope του.
:::
::::

:::::callout (kind := "exercise") (title := "Άσκηση 4 — Από το δέντρο στον κώδικα")
```
lam (f)
├── forallE (_, Nat, Nat)
└── lam (x)
    ├── Nat
    └── app
        ├── bvar 1
        └── app
            ├── bvar 1
            └── bvar 0
```
Γράψε την έκφραση με `fun`. Γιατί τα δύο `bvar 1` είναι η ίδια μεταβλητή, παρόλο που
βρίσκονται σε διαφορετικό βάθος;

::::solution
*`fun (f : Nat → Nat) => fun (x : Nat) => f (f x)`.* Συχνό λάθος είναι να γραφτεί `f f x`,
χωρίς παρενθέσεις.

Η εφαρμογή είναι *αριστερά προσεταιριστική*, οπότε `f f x` σημαίνει `(f f) x`, δηλαδή η `f`
εφαρμόζεται στον εαυτό της, που δεν είναι well-typed:

```lean +error (name := ffx)
#check fun (f : Nat → Nat) (x : Nat) => f f x
```
```leanOutput ffx (severity := Lean.MessageSeverity.error)
Application type mismatch: The argument
  f
has type
  Nat → Nat
but is expected to have type
  Nat
in the application
  f f
```

:::table +header
*
  * Έκφραση
  * Σημαίνει
  * Προσεταιριστικότητα
*
  * `f a b`
  * `(f a) b`
  * αριστερή
*
  * `A → B → C`
  * `A → (B → C)`
  * δεξιά
:::

Για τους δείκτες: μετράει το βάθος του _context_, και η `app` δεν συνεισφέρει.
Ο δείκτης μετράει *binders* ανάμεσα στην αναφορά και στον binder της, όχι κόμβους του δέντρου.
Η `app` δεν εισάγει binder.
::::
:::::

:::callout (kind := "summary")
* *App:* αν $`f : A \to B` και $`a : A`, τότε $`f\,a : B`. Η εφαρμογή δεν επεκτείνει το context.
* Η `lam` κατασκευάζει, η `app` χρησιμοποιεί, η `forallE` περιγράφει.
* Το όρισμα μιας `app` μπορεί να είναι μεταβλητή. Αρκεί ο τύπος του.
* `f a b = (f a) b`, ενώ `A → B → C = A → (B → C)`.
* Οι De Bruijn indices μετράνε binders, όχι βάθος δέντρου.
:::
