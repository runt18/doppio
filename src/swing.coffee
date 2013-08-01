"use strict"

window.swing or= {
  containers: {}
}

$(->
  swing.templates = {}
  for s in ['window', 'icon']
    swing.templates[s] = _.template($("##{s}-tmpl").html())
)

class swing.Icon
  constructor: (@title, @id) ->
    @tmpl = swing.templates.icon
    @el = $(@tmpl({title: @title}))
    @el.click(=>
      $('.swing-window').css({'z-index': 10})
      $("#frame-#{@id}").css({'z-index': 100})
    )

class swing.Taskbar
  constructor: ->
    @el = $('<ul id="taskbar">')
    @el.sortable(
      axis: 'x'
      containment: 'parent'
    ).disableSelection()
    @icons = []

  render: ->
    $('#viewer').append(@el)

  # update: ->
  #   @el.empty()

  #   for container of swing.containers
  #     icon = new swing.Icon(container.title, container.id)
  #     @el.append(icon.el)
  #     @icons.push(icon)

class swing.Frame
  constructor: (@title='untitled', @height=0, @width=0) ->
    frame = this
    @id = "#{Date.now()}"
    @tmpl = swing.templates.window
    @el = $(@tmpl({title: @title}))
    @el.draggable(
      handle: '.title'
      containment: 'parent'
      stack: '.swing-window'
    )
    .resizable()
    .attr('id', "frame-#{@id}")
    .find('.close').click(=>
      frame.el.remove()
      delete swing.containers[frame.id]
      frame.icon.el.remove()
    )

    @canvas = @el.find('.renderer')
    @canvas.attr
      width: @width
      height: @height

    @ctx = @canvas[0].getContext('2d')

    swing.containers[@id] = this
    @icon = new swing.Icon(@title, @id)

  render: ->
    $('#desktop').append(@el)
    swing.taskbar.el.append(@icon.el)

class swing.Label
  constructor: (@parent=null, @value='', @height=0, @width=0) ->

  render: ->
    {ctx} = @parent
    ctx.beginPath()
    ctx.rect(0, 0, @width, @height)
    ctx.stroke()
    ctx.fillText(@value, 0, @height)

swing.taskbar = new swing.Taskbar()
