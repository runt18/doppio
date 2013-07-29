"use strict"

window.swing or= {
  containers: []
}




class swing.Taskbar
  constructor: () ->
    @el = $('<ul id="taskbar">')
    @el.sortable(axis: 'x').disableSelection()

  render: ->
    $('#viewer').append(@el)

  update: ->
    @el.empty()

    for container in swing.containers
      @el.append($('<li class="icon">').text(container.title))

class swing.Frame
  constructor: (@title='untitled', @height=0, @width=0) ->
    @wndw = $(_.template($('#window-tmpl').html(), {title: @title}))
    @wndw.draggable(
      handle: '.title'
      containment: 'parent'
      stack: '.swing-window'
    )
    .resizable()

    @canvas = @wndw.find('.renderer')
    @canvas.attr
      width: @width
      height: @height

    @ctx = @canvas[0].getContext('2d')

    swing.containers.push(this)

  render: ->
    $('#desktop').append(@wndw)
    swing.taskbar.update()

class swing.Label
  constructor: (@parent=null, @value='', @height=0, @width=0) ->

  render: ->
    {ctx} = @parent
    ctx.beginPath()
    ctx.rect(0, 0, @width, @height)
    ctx.stroke()
    ctx.fillText(@value, 0, @height)

    swing.taskbar.update()

swing.taskbar = new swing.Taskbar()
