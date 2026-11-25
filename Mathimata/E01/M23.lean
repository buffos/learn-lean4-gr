import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.23 — Substitution με De Bruijn Indices" =>

%%%
tag := "m1-23"
file := "1-23"
number := false
%%%

:::callout (kind := "goals")
* Να κάνεις μια απλή β-reduction πάνω στο δέντρο με De Bruijn indices.
* Να καταλάβεις ότι και η *αφαίρεση* ενός binder αλλάζει δείκτες, ακόμη κι αν η μεταβλητή του δεν χρησιμοποιείται.
:::

# Ένα απλό παράδειγμα

%%%
tag := "1-23-simple"
%%%

```lean
#check (fun (x : Nat) => fun (y : Nat) => x) 5
```

```
app                              lam (y)
├── lam (x)                      ├── Nat
│   ├── Nat           ──β──▶     └── lit 5
│   └── lam (y)
│       ├── Nat
│       └── bvar 1   -- x
└── lit 5
```

Αφαιρούμε την εξωτερική `lam` και βάζουμε το `5` εκεί που ήταν η αναφορά στο `x`. Αποτέλεσμα:
`fun (y : Nat) => 5`. Εδώ δεν χρειάζεται shifting, γιατί το `5` δεν περιέχει αναφορές σε binders.

```lean
example : (fun (x : Nat) => fun (_ : Nat) => x) 5 = fun _ => 5 := rfl
```

# Όταν αφαιρείται ένας binder

%%%
tag := "1-23-remove"
%%%

Η μετατόπιση δεν χρειάζεται μόνο όταν *προσθέτουμε* binders, αλλά και όταν *αφαιρούμε*:

```lean
#check fun (z : Nat) => (fun (_x : Nat) => z) 5
```

```
lam (z)
├── Nat
└── app
    ├── lam (x)
    │   ├── Nat
    │   └── bvar 1       -- z
    └── lit 5
```

Το `x` δεν χρησιμοποιείται καθόλου. Η αφαίρεση του binder του όμως επηρεάζει την αναφορά στο `z`.

::::callout (kind := "exercise")
Μετά από β-reduction στην εσωτερική `app` έχουμε `lam (z) (Nat) (bvar ?)`. Ποιος είναι ο νέος δείκτης;
Γιατί αλλάζει, αφού το `x` δεν εμφανίζεται στο body;

:::solution
*`bvar 0`.* Αφαιρέθηκε ο binder `x`, και ο `z` είναι πλέον ο πλησιέστερος binder.

Δεν αντικαταστάθηκε καμία αναφορά στο `x`. Η αφαίρεση του binder του όμως άλλαξε το _πλαίσιο
αναφοράς_ για όσα βρίσκονταν από κάτω. Οι εξωτερικές αναφορές «κατεβαίνουν» κατά 1.
:::
::::

:::callout (kind := "summary")
* β-reduction: αφαιρούμε τη `lam` και αντικαθιστούμε τις αναφορές στον binder της με το όρισμα.
* Όταν αφαιρείται binder, οι αναφορές σε *εξωτερικούς* binders μειώνονται κατά 1.
* Αυτό γίνεται ακόμη κι όταν η αφαιρούμενη μεταβλητή δεν χρησιμοποιείται.
:::
