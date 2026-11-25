import VersoManual
import Mathimata

open Verso Genre Manual

def theme : Verso.Genre.Manual.CSS := ⟨include_str "static/theme.css"⟩

def config : RenderConfig where
  emitTeX := false
  emitHtmlSingle := .no
  emitHtmlMulti := .immediately
  htmlDepth := 2
  extraCss := {theme}
  extraJs := {⟨include_str "static/page-toc.js"⟩}
  sourceLink := some "https://github.com/buffos/learn-lean4-gr"
  issueLink := some "https://github.com/buffos/learn-lean4-gr/issues"

def main := manualMain (%doc Mathimata) (config := config)
