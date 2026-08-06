(function () {
  "use strict";
  mermaid.initialize({
    startOnLoad: false,
    securityLevel: "strict",
    theme: "neutral",
    deterministicIds: true,
    deterministicIDSeed: "software-engineering-fundamentals",
    fontFamily: "Inter, Helvetica Neue, Arial, sans-serif",
    flowchart: {
      htmlLabels: false,
      useMaxWidth: true,
      curve: "linear",
      nodeSpacing: 42,
      rankSpacing: 52,
      padding: 12
    },
    sequence: {
      useMaxWidth: true,
      wrap: true,
      diagramMarginX: 24,
      diagramMarginY: 18,
      actorMargin: 55,
      messageMargin: 28,
      mirrorActors: false
    },
    themeCSS: [
      ".node rect,.node circle,.node ellipse,.node polygon,.node path{stroke:#111!important;stroke-width:1.5px!important;}",
      ".edgePath path,.flowchart-link{stroke:#111!important;}",
      ".edgeLabel rect{fill:#fff!important;opacity:1!important;}",
      ".cluster rect{fill:#fff!important;stroke:#555!important;stroke-dasharray:5 4!important;}",
      ".actor{fill:#fff!important;stroke:#111!important;}",
      ".messageLine0,.messageLine1{stroke:#111!important;}",
      ".label,.nodeLabel,.edgeLabel,.messageText,.noteText{fill:#000!important;color:#000!important;}"
    ].join("")
  });

  window.addEventListener("DOMContentLoaded", async function () {
    try {
      const cover = document.querySelector(".book-cover");
      const toc = document.querySelector("nav#TOC");
      if (cover && toc && toc.parentNode) {
        toc.parentNode.insertBefore(cover, toc);
      }
      if (toc) {
        toc.id = "contents";
        const progress = document.createElement("div");
        progress.className = "reader-progress";
        progress.setAttribute("aria-hidden", "true");
        document.body.appendChild(progress);

        const contentsLink = document.createElement("a");
        contentsLink.className = "reader-contents-link";
        contentsLink.href = "#contents";
        contentsLink.textContent = "Contents";
        document.body.appendChild(contentsLink);

        const updateProgress = function () {
          const available = document.documentElement.scrollHeight - window.innerHeight;
          const ratio = available > 0 ? window.scrollY / available : 0;
          progress.style.transform = "scaleX(" + Math.max(0, Math.min(1, ratio)) + ")";
        };
        window.addEventListener("scroll", updateProgress, { passive: true });
        updateProgress();
      }
      await mermaid.run({ querySelector: ".mermaid" });
      document.documentElement.dataset.mermaidReady = "true";
      document.dispatchEvent(new CustomEvent("handbook:mermaid-ready"));
    } catch (error) {
      document.documentElement.dataset.mermaidReady = "error";
      document.documentElement.dataset.mermaidError =
        String(error && error.message ? error.message : error);
      console.error(error);
    }
  });
}());
