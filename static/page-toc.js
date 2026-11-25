// «Σε αυτή τη σελίδα»: δεξιά στήλη με τις ενότητες της τρέχουσας σελίδας.
// Χτίζεται από τα <h2> του <main>· τονίζει την ενότητα που διαβάζεται.
document.documentElement.lang = "el";

document.addEventListener("DOMContentLoaded", () => {
  // Ελληνικός τίτλος για τον κεντρικό πίνακα περιεχομένων
  document.querySelectorAll("#toc .split-toc.book .title span").forEach(s => {
    if (s.textContent.trim() === "Table of Contents") s.textContent = "Περιεχόμενα";
  });
  const main = document.querySelector("main .content-wrapper");
  if (!main) return;

  // Breadcrumb: Αρχική / Ενότητα / (σελίδα), χτισμένο από τα split-tocs του μενού.
  {
    const crumbs = [];
    const home = document.querySelector("header a.header-title");
    if (home) crumbs.push({ href: home.getAttribute("href") || "./", text: "Αρχική" });
    document.querySelectorAll("#toc .split-toc:not(.book) > .title a").forEach(a => {
      crumbs.push({ href: a.getAttribute("href"), text: a.textContent.trim() });
    });
    const h1 = main.querySelector("h1");
    if (h1 && crumbs.length > 0) {
      const nav = document.createElement("nav");
      nav.className = "breadcrumb";
      nav.setAttribute("aria-label", "Πού βρίσκομαι");
      const pageTitle = h1.textContent.replace(/🔗/g, "").trim();
      crumbs.filter(c => c.text !== pageTitle).forEach(c => {
        const a = document.createElement("a");
        a.href = c.href;
        a.textContent = c.text;
        nav.appendChild(a);
        const sep = document.createElement("span");
        sep.className = "sep";
        sep.textContent = "/";
        nav.appendChild(sep);
      });
      const cur = document.createElement("span");
      cur.className = "here";
      cur.textContent = pageTitle;
      nav.appendChild(cur);
      if (nav.querySelectorAll("a").length > 0) h1.parentNode.insertBefore(nav, h1);
    }
  }

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
    // πλήρης διαδρομή: η σελίδα έχει <base href>, οπότε το σκέτο "#id" θα πήγαινε στην αρχική
    a.href = location.pathname + location.search + "#" + encodeURIComponent(id);
    a.addEventListener("click", e => {
      e.preventDefault();
      h.scrollIntoView({ behavior: "smooth", block: "start" });
      history.replaceState(null, "", a.href);
    });
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
