// nav.js: hover-driven nav dropdowns (the Profiles overlay).
// Hover opens; a short close delay lets the cursor cross the gap into the
// panel without it snapping shut. Click and keyboard work too, for touch and
// accessibility. No dependencies.
(function () {
  "use strict";
  var CLOSE_DELAY = 140; // ms grace period on mouseleave

  function wire(menu) {
    var trigger = menu.querySelector(".menu-trigger");
    var timer;

    function open() {
      clearTimeout(timer);
      menu.classList.add("open");
      if (trigger) trigger.setAttribute("aria-expanded", "true");
    }
    function close() {
      menu.classList.remove("open");
      if (trigger) trigger.setAttribute("aria-expanded", "false");
    }
    function deferClose() {
      clearTimeout(timer);
      timer = setTimeout(close, CLOSE_DELAY);
    }

    menu.addEventListener("mouseenter", open);
    menu.addEventListener("mouseleave", deferClose);
    menu.addEventListener("focusin", open);
    menu.addEventListener("focusout", function (e) {
      if (!menu.contains(e.relatedTarget)) close();
    });

    if (trigger) {
      // touch / click: toggle without navigating
      trigger.addEventListener("click", function (e) {
        e.preventDefault();
        menu.classList.contains("open") ? close() : open();
      });
    }
    menu.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        close();
        if (trigger) trigger.focus();
      }
    });
  }

  document.querySelectorAll(".nav .menu").forEach(wire);
})();
