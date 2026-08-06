(function () {
  "use strict";
  window.PagedConfig = { auto: false };
  document.addEventListener("handbook:mermaid-ready", async function () {
    try {
      const flow = await window.PagedPolyfill.preview();
      document.documentElement.dataset.pagedReady = "true";
      document.documentElement.dataset.pageCount = String(flow.total);
    } catch (error) {
      document.documentElement.dataset.pagedReady = "error";
      document.documentElement.dataset.pagedError =
        String(error && error.message ? error.message : error);
      console.error(error);
    }
  });
}());
