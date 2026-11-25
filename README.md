# Μαθαίνω Lean 4 (learn-lean4-gr)

Σειρά μαθημάτων για τη Lean 4 στα ελληνικά, γραμμένη με [Verso](https://github.com/leanprover/verso).
Κάθε κομμάτι κώδικα Lean ελέγχεται από τον compiler κατά το build.

## Δομή

```
Mathimata.lean            ρίζα του βιβλίου (αρχική σελίδα)
Mathimata/Meta.lean       δικά μας στοιχεία: :::callout, :::solution, :::figure
Mathimata/Xekinima.lean   «Πώς να διαβάσεις τα μαθήματα»
Mathimata/E01.lean        Ενότητα 01 (εισαγωγή + χάρτης)
Mathimata/E01/M01.lean    Μάθημα 1.1, ...
static/theme.css          εμφάνιση
static/fig/e01/*.svg      διαγράμματα (ενσωματώνονται inline)
raw/                      πηγή: οι αρχικές συζητήσεις (δεν δημοσιεύεται)
```

## Προσθήκη μαθήματος

1. Νέο αρχείο `Mathimata/E01/M03.lean` (αντέγραψε τη δομή του `M02.lean`).
2. `import Mathimata.E01.M03` και `{include 2 Mathimata.E01.M03}` στο `Mathimata/E01.lean`.

## Build

Στα Windows το Verso δεν κάνει link (shared lib + md4c), οπότε τα builds γίνονται σε Linux:

```sh
wsl -d Ubuntu -- bash ./build.sh      # Windows → WSL
./build.sh                             # Linux/macOS
```

Το αποτέλεσμα είναι στο `_out/html-multi/`. Για προβολή:
`python -m http.server -d _out/html-multi 8000`.

Σε κάθε push στο `main`, το GitHub Action ([.github/workflows/pages.yml](.github/workflows/pages.yml))
κάνει build και ανεβάζει το site στο GitHub Pages
(Settings → Pages → Source: *GitHub Actions*).
