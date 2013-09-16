# called every time a new page is loaded (see https://github.com/rails/turbolinks/)
page_init = () ->
  # focus the password field
  $("#password-field").focus()

# called once when the DOM is ready
$(document).ready () ->
  page_init()
  document.addEventListener("page:change", page_init)
