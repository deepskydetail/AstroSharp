// Vertical Tab Input binding

var shinyMode =
  typeof window.Shiny !== "undefined" && !!window.Shiny.inputBindings;

if (shinyMode) {
  var VerticalTabInputBinding = new Shiny.InputBinding();
  $.extend(VerticalTabInputBinding, {
    initialize: function(el) {
      $(el).on("click", "> *", function(e) {
        e.preventDefault();
        $(this)
          .siblings("a.active")
          .removeClass("active");
        $(this).addClass("active");
        $(this).css("display", "");
        var index = $(this).index();
        $(this)
          .parents(".vrtc-tab-panel-container")
          .find("div.vrtc-tab-panel>div.vrtc-tab-panel-content")
          .removeClass("active")
          .trigger("hidden.bs.collapse");
        $(this)
          .parents(".vrtc-tab-panel-container")
          .find("div.vrtc-tab-panel>div.vrtc-tab-panel-content")
          .eq(index)
          .addClass("active")
          .trigger("shown.bs.collapse");
      });
    },
    find: function(scope) {
      return $(scope).find(".vertical-tab-panel");
    },
    getId: function(el) {
      return el.id;
    },
    getValue: function(el) {
      return $(el)
        .find(".active")
        .attr("data-value");
    },
    setValue: function setValue(el, value) {},
    receiveMessage: function(el, data) {
      var $el = $(el);

      if (data.hasOwnProperty("value")) {
        $el.find("[data-value='" + data.value + "']").click();
      } else if (data.hasOwnProperty("validate")) {
        if ($el.children(".active").length === 0 && $el.children().length > 0) {
          $el
            .children()
            .last()
            .click();
        }
      } else if (data.hasOwnProperty("reorder")) {
        var items = $el.children();
        items.detach();
        $el.append(
          $.map(data.reorder, function(v) {
            return items[v - 1];
          })
        );
      }
    },
    subscribe: function(el, callback) {
      $(el).on("click", function(event) {
        callback();
      });
    },
    unsubscribe: function(el) {
      $(el).off(".VerticalTabInputBinding");
    }
  });
  Shiny.inputBindings.register(
    VerticalTabInputBinding,
    "shinyWidgets.VerticalTabInput"
  );
} else {
  $(document).ready(function() {
    $("div.vrtc-tab-panel-menu>div.list-group").on("click", "> *", function(e) {
      e.preventDefault();
      $(this)
        .siblings("a.active")
        .removeClass("active");
      $(this).addClass("active");
      $(this).css("display", "");
      var index = $(this).index();
      $(this)
        .parents(".vrtc-tab-panel-container")
        .find("div.vrtc-tab-panel>div.vrtc-tab-panel-content")
        .removeClass("active")
        .trigger("hidden.bs.collapse");
      $(this)
        .parents(".vrtc-tab-panel-container")
        .find("div.vrtc-tab-panel>div.vrtc-tab-panel-content")
        .eq(index)
        .addClass("active")
        .trigger("shown.bs.collapse");
    });
  });
}

