import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.19 — Ο κανόνας τύπων του let" =>

%%%
tag := "m1-19"
file := "1-19"
number := false
%%%

:::callout (kind := "goals")
* Να ξέρεις τον κανόνα _Let_ και τι ελέγχει.
* Να καταλάβεις τον ρόλο του ορισμού $`x := a` μέσα στο context.
:::

# Ο κανόνας

%%%
tag := "1-19-rule"
%%%

$$`\dfrac{\Gamma \vdash A : \mathsf{Sort}\ u \qquad \Gamma \vdash a : A \qquad \Gamma,\ x : A := a \vdash t : B}{\Gamma \vdash (\mathsf{let}\ x : A := a;\ t) : B[x := a]}\ \textsf{(Let)}`

Τρεις έλεγχοι:

1. Ο δηλωμένος τύπος $`A` να είναι πράγματι τύπος.
2. Η τιμή $`a` να έχει τον τύπο $`A`. (Αυτός είναι ο έλεγχος που *δεν* υπάρχει στο `lam`.)
3. Το body $`t` να έχει κάποιον τύπο $`B` στο context, επεκταμένο με τον ορισμό.

Ο τύπος του αποτελέσματος είναι το $`B`, με το $`x` αντικατεστημένο από το $`a`. Το $`B`
μπορεί να αναφέρεται στο $`x`, που όμως δεν υπάρχει έξω από το `let`.

```
inferType(letE(x, A, a, t), Γ):
  sort(u) ← inferType(A, Γ)
  T ← inferType(a, Γ)
  if not defEq(T, A): error "type mismatch"
  B ← inferType(t, extend(Γ, x : A := a))
  return instantiate1(B, a)
```

# Γιατί μετράει ο ορισμός

%%%
tag := "1-19-why"
%%%

Ο ορισμός $`x := a` στο context δεν είναι διακοσμητικός: επιτρέπει στον kernel να
_ξεδιπλώσει_ το $`x` όταν χρειάζεται. Αυτό φαίνεται όταν ο τύπος εξαρτάται από την τιμή:

```lean (name := letDep)
#check let n : Nat := 3; (fun (v : Fin 4) => v) (0 : Fin (n + 1))
```

Για να περάσει ο έλεγχος, ο kernel πρέπει να δει ότι το `Fin (n + 1)` είναι το ίδιο με
το `Fin 4`. Αυτό γίνεται μόνο επειδή ξέρει ότι `n := 3`. Με ένα `fun (n : Nat) => …`, όπου το
`n` δεν έχει τιμή, ο ίδιος έλεγχος θα αποτύγχανε:

```lean +error (name := lamNoVal)
#check fun (n : Nat) => (fun (v : Fin 4) => v) (0 : Fin (n + 1))
```

Το πώς ακριβώς ελέγχει ο kernel ότι δύο τύποι είναι «ίδιοι» είναι το θέμα της
_definitional equality_, που θα τη μελετήσουμε σε επόμενη ενότητα.

:::callout (kind := "summary")
* *Let:* ελέγχει τον τύπο, ότι η τιμή έχει αυτόν τον τύπο, και το body στο $`\Gamma, x : A := a`.
* Ο τύπος του αποτελέσματος είναι $`B[x := a]`.
* Ο ορισμός μέσα στο context επιτρέπει στον kernel να ξεδιπλώνει το $`x` όταν συγκρίνει τύπους.
:::
