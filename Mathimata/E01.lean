import VersoManual
import Mathimata.Meta
import Mathimata.E01.M01
import Mathimata.E01.M02

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Mathimata

#doc (Manual) "Ενότητα 01 — Terms, Types & Typing Judgments" =>

%%%
tag := "e01"
file := "e01"
number := false
%%%

Σε αυτή την ενότητα μαθαίνουμε πώς ο *kernel* της Lean 4 λειτουργεί ως
_type checker_. Ξεκινάμε από το πιο βασικό ερώτημα (τι είναι ένα term;) και
φτάνουμε μέχρι τους κανόνες για συναρτήσεις, μεταβλητές, αντικατάσταση και universes.

Δεν θα χρησιμοποιήσουμε ακόμη _tactics_ ή αποδείξεις. Μας ενδιαφέρει ο
πυρήνας: τι ακριβώς ελέγχεται, και με ποιους κανόνες.

:::figure (src := "e01/roadmap.svg") (caption := "Ο χάρτης της ενότητας. Τα μαθήματα που έχουν δημοσιευτεί είναι τονισμένα.")
:::

{include 2 Mathimata.E01.M01}

{include 2 Mathimata.E01.M02}
