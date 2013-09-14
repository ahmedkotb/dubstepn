# called every time a new page is loaded (see https://github.com/rails/turbolinks/)
page_init = () ->
  # make a textarea automatically adjust its height based on its content
  window.fit_textarea = (selector) ->
    # loop through each textarea
    $(selector).each (index, element) ->
      # get the textarea
      textarea = $(element)

      # generate a unique id for the doppelganger div
      doppelganger_id = "textarea-doppelganger-" + String(index)

      # create the doppelganger
      $(element).after("<div id='" + doppelganger_id + "' />")
      doppelganger = $("#" + doppelganger_id)

      # clone the styles from the textarea
      for prop in [
        "font-family",
        "font-size",
        "font-style",
        "font-variant",
        "font-weight",
        "font-size-adjust",
        "font-stretch",
        "overflow-x",
        "overflow-y",
        "display",
        "padding-top",
        "padding-right",
        "padding-bottom",
        "padding-left",
        "border-top",
        "border-right",
        "border-bottom",
        "border-left",
        "box-sizing",
        "line-height",
        "text-align",
        "text-indent",
        "vertical-align",
        "white-space",
        "word-spacing",
        "word-wrap",
        "width",
      ]
        doppelganger.css(prop, textarea.css(prop))

      # fill the doppelganger with the content of the textarea
      doppelganger.text(textarea.val() + " ")

      # resize the textarea based on the height of the doppelganger
      textarea.height(Math.max(doppelganger.height(), 64) + "px")

      # destroy the doppelganger
      doppelganger.remove()

  # make all textareas auto-resize
  $("textarea").each (index, element) ->
    if !$(element).hasClass("auto-resize")
      $(element).addClass("auto-resize")
      $(element).change (e) -> fit_textarea(this)
      $(element).bind "input keyup propertychange", (e) -> fit_textarea(this)
      fit_textarea(element)

# called once when the DOM is ready
$(document).ready () ->
  page_init()
  document.addEventListener("page:change", page_init)