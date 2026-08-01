(function () {
  "use strict";

  var navToggle = document.querySelector("[data-nav-toggle]");
  var siteNav = document.querySelector("[data-site-nav]");

  function closeNavigation() {
    if (!navToggle || !siteNav) return;
    navToggle.setAttribute("aria-expanded", "false");
    siteNav.classList.remove("is-open");
  }

  if (navToggle && siteNav) {
    navToggle.addEventListener("click", function () {
      var expanded = navToggle.getAttribute("aria-expanded") === "true";
      navToggle.setAttribute("aria-expanded", String(!expanded));
      siteNav.classList.toggle("is-open", !expanded);
    });

    siteNav.addEventListener("click", function (event) {
      if (event.target.closest("a")) closeNavigation();
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        closeNavigation();
        navToggle.focus();
      }
    });

    window.addEventListener("resize", function () {
      if (window.matchMedia("(min-width: 865px)").matches) closeNavigation();
    });
  }

  document.querySelectorAll("[data-copy-email]").forEach(function (button) {
    button.addEventListener("click", function () {
      var email = button.getAttribute("data-copy-email");
      var status = button.parentElement.querySelector("[data-copy-status]");

      function report(message) {
        if (!status) return;
        status.textContent = message;
        window.setTimeout(function () { status.textContent = ""; }, 2200);
      }

      if (!navigator.clipboard) {
        report("Select the address to copy");
        return;
      }

      navigator.clipboard.writeText(email).then(function () {
        report("Copied");
      }).catch(function () {
        report("Copy failed");
      });
    });
  });

  var filterPanel = document.querySelector("[data-filter-panel]");
  var researchItems = Array.prototype.slice.call(document.querySelectorAll("[data-research-item]"));

  if (filterPanel && researchItems.length) {
    var search = filterPanel.querySelector("[data-research-search]");
    var count = document.querySelector("[data-results-count]");
    var emptyState = document.querySelector("[data-empty-state]");
    var resetButton = document.querySelector("[data-reset-filters]");
    var state = { type: "all", topic: "all", query: "" };

    function setPressed(group, selectedValue) {
      filterPanel.querySelectorAll('[data-filter-group="' + group + '"] [data-filter-value]').forEach(function (button) {
        var active = button.getAttribute("data-filter-value") === selectedValue;
        button.classList.toggle("is-active", active);
        button.setAttribute("aria-pressed", String(active));
      });
    }

    function updateUrl() {
      if (!window.history || !window.history.replaceState) return;
      var params = new URLSearchParams();
      if (state.type !== "all") params.set("status", state.type);
      if (state.topic !== "all") params.set("topic", state.topic);
      if (state.query) params.set("q", state.query);
      var query = params.toString();
      window.history.replaceState({}, "", window.location.pathname + (query ? "?" + query : "") + window.location.hash);
    }

    function applyFilters(updateAddress) {
      var visible = 0;
      var normalizedQuery = state.query.trim().toLowerCase();

      researchItems.forEach(function (item) {
        var typeMatch = state.type === "all" || item.getAttribute("data-type") === state.type;
        var topics = item.getAttribute("data-topics") || "";
        var topicMatch = state.topic === "all" || topics.indexOf("|" + state.topic + "|") !== -1;
        var haystack = (item.getAttribute("data-search") || "").toLowerCase();
        var searchMatch = !normalizedQuery || haystack.indexOf(normalizedQuery) !== -1;
        var show = typeMatch && topicMatch && searchMatch;
        item.hidden = !show;
        if (show) visible += 1;
      });

      if (count) count.textContent = visible + (visible === 1 ? " item" : " items");
      if (emptyState) emptyState.hidden = visible !== 0;
      if (updateAddress) updateUrl();
    }

    filterPanel.querySelectorAll("[data-filter-group]").forEach(function (group) {
      group.addEventListener("click", function (event) {
        var button = event.target.closest("[data-filter-value]");
        if (!button) return;
        var groupName = group.getAttribute("data-filter-group");
        state[groupName] = button.getAttribute("data-filter-value");
        setPressed(groupName, state[groupName]);
        applyFilters(true);
      });
    });

    if (search) {
      search.addEventListener("input", function () {
        state.query = search.value;
        applyFilters(true);
      });
    }

    if (resetButton) {
      resetButton.addEventListener("click", function () {
        state = { type: "all", topic: "all", query: "" };
        if (search) search.value = "";
        setPressed("type", "all");
        setPressed("topic", "all");
        applyFilters(true);
        if (search) search.focus();
      });
    }

    var initialParams = new URLSearchParams(window.location.search);
    var requestedType = initialParams.get("status");
    var requestedTopic = initialParams.get("topic");
    var requestedQuery = initialParams.get("q") || "";

    if (requestedType && filterPanel.querySelector('[data-filter-group="type"] [data-filter-value="' + CSS.escape(requestedType) + '"]')) {
      state.type = requestedType;
    }
    if (requestedTopic && filterPanel.querySelector('[data-filter-group="topic"] [data-filter-value="' + CSS.escape(requestedTopic) + '"]')) {
      state.topic = requestedTopic;
    }
    state.query = requestedQuery;
    if (search) search.value = requestedQuery;
    setPressed("type", state.type);
    setPressed("topic", state.topic);
    applyFilters(false);
  }

  var backToTop = document.querySelector("[data-back-to-top]");
  if (backToTop) {
    function updateBackToTop() {
      backToTop.hidden = window.scrollY < 700;
    }

    backToTop.addEventListener("click", function () {
      var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
      window.scrollTo({ top: 0, behavior: reduceMotion ? "auto" : "smooth" });
    });

    window.addEventListener("scroll", updateBackToTop, { passive: true });
    updateBackToTop();
  }
}());
