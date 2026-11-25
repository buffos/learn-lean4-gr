import VersoManual
import Mathimata.Meta
import Mathimata.Xekinima
import Mathimata.E01

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

set_option pp.rawOnError true

#doc (Manual) "Μαθαίνω Lean 4" =>

%%%
shortTitle := "Lean 4 στα ελληνικά"
%%%

Μια σειρά μαθημάτων για τη *Lean 4* στα ελληνικά, που ξεκινάει από τα θεμέλια:
πώς ο _kernel_ της Lean ελέγχει ότι μια έκφραση έχει τον τύπο που ισχυριζόμαστε.

Κάθε μάθημα έχει θεωρία, παραδείγματα και ερωτήσεις κατανόησης με λύσεις. Ιδιαίτερη
έμφαση δίνεται στα *συνηθισμένα λάθη*, τις παρανοήσεις που κάνει σχεδόν όποιος μαθαίνει
τη θεωρία τύπων για πρώτη φορά, και στο γιατί είναι λάθη.

:::callout (kind := "tip") (title := "Ο κώδικας εδώ είναι ζωντανός")
Κάθε κομμάτι κώδικα Lean σε αυτή τη σελίδα το έχει ελέγξει η ίδια η Lean
κατά τη δημιουργία του site. Πέρασε τον κέρσορα πάνω από ένα όνομα, π.χ. το `Nat`,
για να δεις τον τύπο του.
:::

{include 1 Mathimata.Xekinima}

{include 1 Mathimata.E01}
