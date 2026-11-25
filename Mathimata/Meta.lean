import VersoManual

/-!
# Δικά μας στοιχεία σελίδας

* `:::callout (kind := "tip") (title := "...")` — πλαίσιο. Είδη:
  `goals`, `tip`, `note`, `mistake`, `exercise`, `summary`, `deep`.
* `:::solution (title := "...")` — αναδιπλούμενη λύση (`<details>`).
* `:::figure (src := "e01/x.svg") (caption := "...")` — ενσωματώνει SVG από `static/fig/`.
-/

open Lean Elab
open Verso ArgParse Doc Elab Genre.Manual
open Verso.Doc.Html (HtmlT)
open Verso.Output

namespace Mathimata

def calloutIcon : String → String
  | "goals" => "🎯"
  | "tip" => "💡"
  | "note" => "📝"
  | "mistake" => "⚠️"
  | "exercise" => "✏️"
  | "summary" => "📌"
  | "deep" => "🔬"
  | _ => "ℹ️"

def calloutDefaultTitle : String → String
  | "goals" => "Στόχοι του μαθήματος"
  | "tip" => "Συμβουλή"
  | "note" => "Σημείωση"
  | "mistake" => "Συνηθισμένο λάθος"
  | "exercise" => "Άσκηση"
  | "summary" => "Σύνοψη"
  | "deep" => "Σε βάθος"
  | _ => ""

block_extension Block.callout (kind : String) (title : String) where
  data := .arr #[.str kind, .str title]
  traverse _ _ _ := pure none
  toTeX := none
  toHtml :=
    open Verso.Output.Html in
    some <| fun _ goB _ data content => do
      let .arr #[.str kind, .str title] := data
        | reportError "bad callout data" *> pure .empty
      let title := if title.isEmpty then calloutDefaultTitle kind else title
      pure html%{
        <div class={"callout callout-" ++ kind}>
          <div class="callout-title"><span class="callout-icon">{calloutIcon kind}</span>{title}</div>
          <div class="callout-body">{← content.mapM goB}</div>
        </div>
      }

block_extension Block.solution (title : String) where
  data := .str title
  traverse _ _ _ := pure none
  toTeX := none
  toHtml :=
    open Verso.Output.Html in
    some <| fun _ goB _ data content => do
      let .str title := data
        | reportError "bad solution data" *> pure .empty
      pure html%{
        <details class="solution">
          <summary>{title}</summary>
          <div class="solution-body">{← content.mapM goB}</div>
        </details>
      }

block_extension Block.figure (svg : String) (caption : String) where
  data := .arr #[.str svg, .str caption]
  traverse _ _ _ := pure none
  toTeX := none
  toHtml :=
    open Verso.Output.Html in
    some <| fun _ _ _ data _ => do
      let .arr #[.str svg, .str caption] := data
        | reportError "bad figure data" *> pure .empty
      pure html%{
        <figure class="lesson-figure">
          {Html.raw svg}
          <figcaption>{caption}</figcaption>
        </figure>
      }

structure CalloutConfig where
  kind : String
  title : String

structure SolutionConfig where
  title : String

structure FigureConfig where
  src : String
  caption : String

section
variable [Monad m] [MonadInfoTree m] [MonadLiftT CoreM m] [MonadEnv m] [MonadError m]

def CalloutConfig.parse : ArgParse m CalloutConfig :=
  CalloutConfig.mk <$> .namedD' `kind "note" <*> .namedD' `title ""

instance : FromArgs CalloutConfig m := ⟨CalloutConfig.parse⟩

def SolutionConfig.parse : ArgParse m SolutionConfig :=
  SolutionConfig.mk <$> .namedD' `title "Δες τη λύση"

instance : FromArgs SolutionConfig m := ⟨SolutionConfig.parse⟩

def FigureConfig.parse : ArgParse m FigureConfig :=
  FigureConfig.mk <$> .named' `src false <*> .namedD' `caption ""

instance : FromArgs FigureConfig m := ⟨FigureConfig.parse⟩
end

@[directive]
def callout : DirectiveExpanderOf CalloutConfig
  | cfg, stxs => do
    let args ← stxs.mapM elabBlock
    ``(Verso.Doc.Block.other (Block.callout $(quote cfg.kind) $(quote cfg.title)) #[ $[ $args ],* ])

@[directive]
def solution : DirectiveExpanderOf SolutionConfig
  | cfg, stxs => do
    let args ← stxs.mapM elabBlock
    ``(Verso.Doc.Block.other (Block.solution $(quote cfg.title)) #[ $[ $args ],* ])

@[directive]
def figure : DirectiveExpanderOf FigureConfig
  | cfg, _ => do
    let path : System.FilePath := "static" / "fig" / cfg.src
    unless (← path.pathExists) do
      throwError "Δεν βρέθηκε το σχήμα {path}"
    let svg ← IO.FS.readFile path
    ``(Verso.Doc.Block.other (Block.figure $(quote svg) $(quote cfg.caption)) #[])

end Mathimata
