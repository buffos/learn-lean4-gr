// «Σε αυτή τη σελίδα»: δεξιά στήλη με τις ενότητες της τρέχουσας σελίδας.
// Χτίζεται από τα <h2> του <main>· τονίζει την ενότητα που διαβάζεται.
document.documentElement.lang = "el";

document.addEventListener("DOMContentLoaded", () => {
  const main = document.querySelector("main .content-wrapper");
  if (!main) return;

  const heads = [...main.querySelectorAll("section h2")].filter(h => h.id || h.closest("section[id]"));
  const here = location.pathname.replace(/\/index\.html$/, "/");

  // Κρύψε από το αριστερό μενού τη λίστα ενοτήτων της ίδιας σελίδας
  // (μόνο σε φαρδιές οθόνες, μέσω της κλάσης has-page-toc).
  document.querySelectorAll("#toc .split-toc").forEach(st => {
    const links = [...st.querySelectorAll("table a")];
    if (links.length && links.every(a => a.pathname.replace(/\/index\.html$/, "/") === here && a.hash)) {
      st.classList.add("page-local-toc");
    }
  });

  if (heads.length < 2) return;

  const nav = document.createElement("nav");
  nav.className = "page-toc";
  nav.setAttribute("aria-label", "Σε αυτή τη σελίδα");
  const title = document.createElement("div");
  title.className = "page-toc-title";
  title.textContent = "Σε αυτή τη σελίδα";
  nav.appendChild(title);
  const ol = document.createElement("ol");
  const items = heads.map(h => {
    const id = h.id || h.closest("section[id]").id;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = "#" + id;
    // κείμενο του τίτλου χωρίς αριθμούς/permalink
    const clone = h.cloneNode(true);
    clone.querySelectorAll(".permalink-widget, .number").forEach(e => e.remove());
    a.textContent = clone.textContent.replace(/🔗/g, "").trim();
    li.appendChild(a);
    ol.appendChild(li);
    return { h, li };
  });
  nav.appendChild(ol);
  document.body.appendChild(nav);
  document.body.classList.add("has-page-toc");

  // Scrollspy: η τελευταία ενότητα που έχει περάσει το πάνω μέρος της οθόνης.
  const offset = () => parseFloat(getComputedStyle(document.documentElement).fontSize) * 6;
  const update = () => {
    let cur = items[0];
    for (const it of items) if (it.h.getBoundingClientRect().top - offset() <= 0) cur = it;
    items.forEach(it => it.li.classList.toggle("active", it === cur));
  };
  addEventListener("scroll", update, { passive: true });
  update();
});
