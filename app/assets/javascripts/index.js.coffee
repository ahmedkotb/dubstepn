# when the DOM is ready
$(document).ready(() ->
  # make sure we delete the right post
  $(".delete_button").click(() ->
    id = Number($(this).attr("id")[14..])
    name = ""
    for post in posts
      do (post) ->
        if post.id == id
          $("span#post_name").html(post.title.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"))
          $("input#post_id_field").val(post.id)
  )

  # apply fancybox to the delete links
  $(".delete_button").fancybox({
    autoSize  : true,
    closeClick  : false,
    openEffect  : 'none',
    closeEffect : 'none',
  })
)