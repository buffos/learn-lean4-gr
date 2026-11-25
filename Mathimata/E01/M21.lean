import VersoManual
import Mathimata.Meta

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "1.21 — Variable Capture" =>

%%%
tag := "m1-21"
file := "1-21"
number := false
%%%

:::callout (kind := "goals")
* Να καταλάβεις γιατί η αντικατάσταση *δεν* είναι απλή αντικατάσταση συμβόλων.
* Να αναγνωρίζεις το φαινόμενο _variable capture_.
* Να καταλάβεις γιατί το type checking από μόνο του δεν το πιάνει.
:::

# Το πρόβλημα

%%%
tag := "1-21-problem"
%%%

Με context $`\Gamma = (y : \mathsf{Nat})`, πάρε την έκφραση:

$$`(\lambda\, x : \mathsf{Nat}.\ \lambda\, y : \mathsf{Nat}.\ x)\ y`

```lean (name := capture)
section
variable (y : Nat)
#check (fun (x : Nat) => fun (y : Nat) => x) y
end
```

Θέλουμε να κάνουμε ένα βήμα β-reduction: να αντικαταστήσουμε το `x` με το *εξωτερικό* `y`.

# Η αφελής αντικατάσταση

%%%
tag := "1-21-naive"
%%%

Αν απλώς γράψουμε `y` όπου υπήρχε `x`, παίρνουμε:

$$`\lambda\, y : \mathsf{Nat}.\ y \qquad \text{✗ ΛΑΘΟΣ}`

Το `y` που βάλαμε *πιάστηκε* από τον εσωτερικό binder `y`, ενώ αρχικά αναφερόταν στη
μεταβλητή του εξωτερικού context. Αυτό λέγεται *variable capture*: αλλάξαμε τη σημασία της
έκφρασης χωρίς να το θέλουμε.

# Η σωστή αντικατάσταση

%%%
tag := "1-21-correct"
%%%

Πρώτα μετονομάζουμε τον εσωτερικό binder σε κάτι καινούργιο (α-renaming), και μετά αντικαθιστούμε:

$$`(\lambda\, x.\ \lambda\, z.\ x)\ y \ \longrightarrow_\beta\ \lambda\, z : \mathsf{Nat}.\ y \qquad \text{✓}`

:::figure (src := "e01/capture.svg") (caption := "Αριστερά η αφελής αντικατάσταση: το y «πιάνεται» και η συνάρτηση γίνεται ταυτοτική. Δεξιά η σωστή: η συνάρτηση είναι σταθερή και επιστρέφει το εξωτερικό y.")
:::

Αυτή η διαδικασία λέγεται *capture-avoiding substitution*.

# Ερωτήσεις κατανόησης

%%%
tag := "1-21-askiseis"
%%%

::::callout (kind := "exercise") (title := "Άσκηση 1 — Διαφορετική συμπεριφορά, ίδιος τύπος;")
Έστω ότι το εξωτερικό `y` είναι 5. Τι δίνουν τα $`(\lambda y.\,y)\ 10` και $`(\lambda z.\,y)\ 10`;
Θα μπορούσε ο kernel να εντοπίσει τη λάθος αντικατάσταση μέσω του type checking;

:::solution
Η πρώτη δίνει *10*, η δεύτερη *5*.

*Όχι*, το type checking δεν βοηθάει: και οι δύο συναρτήσεις έχουν body τύπου `Nat`, άρα και οι
δύο έχουν τύπο `Nat → Nat`. Είναι well-typed, αλλά συμπεριφέρονται διαφορετικά.

```lean
section
variable (y : Nat)
#check fun (y : Nat) => y     -- Nat → Nat
#check fun (z : Nat) => y     -- Nat → Nat
end
```

Γι' αυτό ο μηχανισμός αντικατάστασης πρέπει να είναι *σωστός από κατασκευής*. Ένα λάθος
εκεί δεν πιάνεται από τους τύπους.
:::
::::

::::callout (kind := "exercise") (title := "Άσκηση 2 — Λύνουν οι De Bruijn indices το πρόβλημα;")
Εξαλείφουν οι De Bruijn indices αυτόματα το variable capture, ή χρειάζεται ειδικός μηχανισμός
προσαρμογής των δεικτών κατά την αντικατάσταση;

:::solution
Χρειάζεται μηχανισμός. Όταν μεταφέρουμε ένα term σε άλλο scope, οι δείκτες του *αλλάζουν
πλαίσιο αναφοράς* και πρέπει να μετατοπιστούν. Οι De Bruijn indices είναι _σχετικοί_, όχι
απόλυτοι.

Με τους indices δεν χρειαζόμαστε μετονομασίες, γιατί δεν υπάρχουν ονόματα για να
συγκρουστούν. Χρειαζόμαστε όμως *index shifting*, που είναι το θέμα του επόμενου μαθήματος.
:::
::::

:::callout (kind := "summary")
* Η αφελής αντικατάσταση μπορεί να «πιάσει» μια ελεύθερη μεταβλητή (*variable capture*).
* Με ονόματα, η λύση είναι να μετονομάσουμε πρώτα τον binder (capture-avoiding substitution).
* Το type checking δεν εντοπίζει το λάθος: η λάθος και η σωστή εκδοχή έχουν τον ίδιο τύπο.
* Με De Bruijn indices χρειαζόμαστε μετατόπιση δεικτών.
:::
