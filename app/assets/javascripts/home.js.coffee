# called every time a new page is loaded (see https://github.com/rails/turbolinks/)
page_init = (first_time) ->
  # make a particular element full-width
  make_full_width = (e) ->
    # get the aspect ratio
    if $(e).attr("width")? and $(e).attr("height")?
      aspect_ratio = Number($(e).attr("width")) / Number($(e).attr("height"))
    else if e.naturalWidth? and e.naturalWidth?
      aspect_ratio = e.naturalWidth / e.naturalHeight
    else
      aspect_ratio = $(e).width() / $(e).height()

    # set a resize handler on an element, but debounced
    # also fires the callback immediately
    debounced_resize = (element, callback) ->
      callback()
      timeout = null
      $(element).resize(() ->
        if timeout?
          clearInterval(timeout)
        timeout = setTimeout((() ->
          callback()
          timeout = null
        ), 300)
      )

    # make the element full-width
    on_resize = () ->
      outer_width = $(e).parent().innerWidth()
      outer_height = Math.round(outer_width / aspect_ratio)
      $(e).width(outer_width)
      $(e).height(outer_height)

    # fire the callback on resize
    debounced_resize(window, on_resize)

  # make all images, iframes, etc. full-width
  $(".article iframe[src^='http://www.youtube.com']").load(() -> make_full_width(this))

  # load MathJax
  if !first_time
    MathJax.Hub.Queue(["Typeset", MathJax.Hub])

# called once when the DOM is ready
$(document).ready () ->
  page_init(true)
  document.addEventListener("page:change",  (() -> page_init(false)))
  document.addEventListener("page:fetch",   (() -> $(".loading-cover").css("visibility", "visible")))
  document.addEventListener("page:receive", (() -> $(".loading-cover").css("visibility", "hidden")))