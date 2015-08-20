###
This is free and unencumbered software released into the public domain.
###

init = ({paths, nonImages}) ->

  rss = $('a[href$=".rss"]').remove()

  imageLinks = []
  for path in paths
    imageLinks.push $('<a>')
      .attr(href: path)
      .text(path)
      .addClass('item')

  $(document.head).append '<link rel="stylesheet" href="/slideshow/slideshow.css"/>'

  body = $(document.body).empty()
  menu = $('<div id="menu"/>').appendTo(body)
  box = $('<div id="box"/>').appendTo(body)
  display = $('<img/>').appendTo(box).hide()

  preload = new Image()
  image = new Image()
  old = $()
  current = $()
  index = 0

  setIndex = (i) ->
    return if not imageLinks[i]
    index = i

    if image.onload
      current.removeClass 'on loading'

    current = $(imageLinks[i])
    current.addClass 'loading'
    menu.stop().scrollTo current, { duration: 300, offset: { top: -100 } }

    image.onload = ->
      # Duplicate image onload bug?
      return if current.attr('href') == old.attr('href')

      current.removeClass 'loading'
      current.addClass 'on'
      old.removeClass 'on loading'
      old = current

      document.location.hash = i

      maxw = box.innerWidth()
      maxh = box.innerHeight()
      w = image.width
      h = image.height
      if not w? or not h? then return
      ratio = Math.min maxw/w, maxh/h

      display
        .show()
        .attr(src: image.src)
        .width(w * ratio)
        .height(h * ratio)
        .css
          display: 'block'
          margin: '0 auto'

      image.onload = null
    image.src = imageLinks[i].attr 'href'

    if imageLinks[i+1]
      preload.src = imageLinks[i+1].attr 'href'

  index = parseInt document.location.hash.substr(1)
  if not isNaN index
    setIndex index
  else
    setIndex 0

  $(window).on 'hashchange', ->
    setIndex parseInt document.location.hash.substr(1)

  for el, i in imageLinks
    do (el, i) ->
      $(el).on 'click', ->
        setIndex i
        return false

  $(document).on 'keydown', (e) ->
    switch String.fromCharCode(e.which).toUpperCase()
      when 'J'
        setIndex index + 1
      when 'K'
        setIndex index - 1

  menu.append """
    <h1>#{ document.title }</h1>
    <p class="notice">
      These items are not the property of this web site and are not subject to the
      license or conditions expressed elsewhere on the site. Their origin may be
      unknown. This part of the site is not indexed.
    </p>
    <p class="meta">Keys: K=prev J=next - <a href="#{ rss.attr 'href' }">RSS feed</a></p>
  """

  if nonImages
    ul = $('<ul>').appendTo menu
    for path in nonImages
      ul.append "<li><a href=\"#{ path }\">#{ path }</a></li>"

  menu.append(imageLinks)

$(document).ready ->
  $.getJSON "images.json", (data, status, xhr) ->
    if status == 'success'
      init data
    else
      document.body.innerHTML = "Couldn't get images.json"
