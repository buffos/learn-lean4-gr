import VersoManual
import Mathimata.Meta
import Mathimata.E01.M01
import Mathimata.E01.M02
import Mathimata.E01.M03
import Mathimata.E01.M04
import Mathimata.E01.M05
import Mathimata.E01.M06
import Mathimata.E01.M07
import Mathimata.E01.M08
import Mathimata.E01.M09
import Mathimata.E01.M10
import Mathimata.E01.M11
import Mathimata.E01.M12
import Mathimata.E01.M13
import Mathimata.E01.M14
import Mathimata.E01.M15
import Mathimata.E01.M16
import Mathimata.E01.M17
import Mathimata.E01.M18
import Mathimata.E01.M19
import Mathimata.E01.M20
import Mathimata.E01.M21
import Mathimata.E01.M22
import Mathimata.E01.M23
import Mathimata.E01.M24
import Mathimata.E01.M25
import Mathimata.E01.M26

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

:::figure (src := "e01/roadmap.svg") (caption := "Ο χάρτης της ενότητας: από τα θεμέλια μέχρι τα universes.")
:::

{include 2 Mathimata.E01.M01}

{include 2 Mathimata.E01.M02}

{include 2 Mathimata.E01.M03}

{include 2 Mathimata.E01.M04}

{include 2 Mathimata.E01.M05}

{include 2 Mathimata.E01.M06}

{include 2 Mathimata.E01.M07}

{include 2 Mathimata.E01.M08}

{include 2 Mathimata.E01.M09}

{include 2 Mathimata.E01.M10}

{include 2 Mathimata.E01.M11}

{include 2 Mathimata.E01.M12}

{include 2 Mathimata.E01.M13}

{include 2 Mathimata.E01.M14}

{include 2 Mathimata.E01.M15}

{include 2 Mathimata.E01.M16}

{include 2 Mathimata.E01.M17}

{include 2 Mathimata.E01.M18}

{include 2 Mathimata.E01.M19}

{include 2 Mathimata.E01.M20}

{include 2 Mathimata.E01.M21}

{include 2 Mathimata.E01.M22}

{include 2 Mathimata.E01.M23}

{include 2 Mathimata.E01.M24}

{include 2 Mathimata.E01.M25}

{include 2 Mathimata.E01.M26}
