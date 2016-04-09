defer = (fn) -> setTimeout fn, 0

class Menu extends React.Component

  constructor: (props) ->
    super(props)
    @state =
      index: null # not zero...

  _parseHash: ->
    index = parseInt(document.location.hash.substr(1), 10)
    index = 0 if isNaN(index)
    return index

  _readHash: =>
    @_setIndex(@_parseHash())

  _setIndex: (index) =>
    index = 0 if index < 0
    index = @rops.paths.length - 1 if index >= @props.paths.length
    return if index is @state.index # in case of infinite loop
    defer =>
      @setState(index: index)
      @props.onChange?(index)
      document.location.hash = '#' + index

  componentDidMount: ->
    window.addEventListener 'hashchange', @_readHash
    window.addEventListener 'keydown', (e) =>
      switch e.code
        when 'KeyJ'
          @_setIndex @state.index + 1
        when 'KeyK'
          @_setIndex @state.index - 1
    if document.location.hash is ''
      document.location.hash = '#0'
    @_readHash()
    return

  render: ->
    <div id="menu">
      {@props.children}
      <p>Use J and K keys to navigate</p>
      <ul>
        {for path, i in @props.paths
          do (path, i) =>
            path = path.replace /\.\w+$/, ''
            className = if i is @state.index then 'active' else ''
            <li key={i}>
              <a href="##{ i }" className={className}>{path}</a>
            </li>
        }
      </ul>
    </div>

class Viewport extends React.Component

  _maybeUpdateVideo: ->
    if @refs.video?
      @refs.video.pause()
      @refs.video.load()
      @refs.video.play()

  componentDidMount: ->
    defer => @_maybeUpdateVideo()

  componentWillReceiveProps: ->
    defer => @_maybeUpdateVideo()

  render: ->
    <div id="viewport">
      {if not @props.path
        <div/>
      else if (/\.webm$/i).test @props.path
        <video ref="video" preload="auto" autoplay="autoplay" muted="muted" loop="loop">
          <source src={@props.path} type="video/webm"/>
        </video>
      else
        <img src={@props.path}/>
      }
    </div>

class Slideshow extends React.Component

  constructor: (props) ->
    super(props)
    @state =
      path: null

  onChange: (index) =>
    @setState(path: @props.paths[index])

  render: ->
    <div id="slideshow">
      <Menu paths={@props.paths} onChange={@onChange}>
        <div dangerouslySetInnerHTML={__html: @props.header}/>
      </Menu>
      <Viewport path={@state.path}/>
    </div>

defer ->
  header = document.body.innerHTML
  document.body.innerHTML = '<div id="container"></div>'
  el = document.getElementById 'container'

  xhr = new XMLHttpRequest()
  xhr.onreadystatechange = ->
    if xhr.readyState is XMLHttpRequest.DONE
      obj = JSON.parse xhr.responseText
      ReactDOM.render <Slideshow paths={obj.paths} header={header}/>, el
  xhr.open 'get', document.location.pathname + 'images.json'
  xhr.send()

