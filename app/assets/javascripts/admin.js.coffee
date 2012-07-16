# when the DOM is ready
$(document).ready(() ->
  # hook the logout button
  $("a#logout_button").click(() ->
    $("form#logout_form").submit()
  )

  # hook the create_post button
  $("a#create_post_button").click(() ->
    $("form#create_post_form").submit()
  )
)