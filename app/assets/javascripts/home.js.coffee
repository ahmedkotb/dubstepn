# called when the DOM is ready
$(document).ready = () ->
  # make a particular element full-width such that aspect ratio is preserved
  make_full_width = (e) ->
    # get the aspect ratio
    if $(e).attr("width")? and $(e).attr("height")?
      aspect_ratio = Number($(e).attr("width")) / Number($(e).attr("height"))
    else if e.naturalWidth? and e.naturalWidth?
      aspect_ratio = e.naturalWidth / e.naturalHeight
    else
      aspect_ratio = $(e).width() / $(e).height()

    # make the element full-width according to the aspect ratio computed above
    on_resize = () ->
      outer_width = $(e).parent().innerWidth()
      outer_height = Math.round(outer_width / aspect_ratio)
      $(e).width(outer_width)
      $(e).height(outer_height)

    # fire the callback on resize
    $(window).resize(debounce(on_resize))
    on_resize()

  # make all youtube videos full-width
  $("iframe[src*='www.youtube.com']").load(() -> make_full_width(this))

  # load MathJax
  if !first_time
    MathJax.Hub.Queue(["Typeset", MathJax.Hub])
