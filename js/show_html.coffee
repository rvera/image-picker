jQuery ->
  $(".show-html").each () ->
    element   = $(this)
    show_link = $("<a href='#' style='margin-left: 12px;'>Show HTML</a>")
    hide_link = $("<a href='#' style='margin-left: 12px;'>Hide HTML</a>")
    code_cont = code_content(element)
    show_link.click (event) ->
      show_link.hide()
      hide_link.show()
      code_cont.show()
      event.preventDefault()
    hide_link.click (event) ->
      show_link.show()
      hide_link.hide()
      code_cont.hide()
      event.preventDefault()
    element.after code_cont
    element.after hide_link
    element.after show_link
    hide_link.hide()
    code_cont.hide()


code_content = (element) ->
  html = element.clone().wrap('<div>').parent().html()
  pre  = $("<pre  class='prettyprint lang-html'>")
  code = $("<code class='prettyprint lang-html'>")
  html = ("      " + html).replace(/\ \ \ \ \ \ /g, "")
  code.text html
  pre.append code
  pre
