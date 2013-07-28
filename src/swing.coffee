"use strict"

window.swing or= {}

class Frame
  constructor: (@title='untitled', @height=0, @width=0) ->

  render: ->
    wndw = $(_.template($('#window-tmpl').html(), {title: @title}))
    viewer = $('#viewer')
    canvas = wndw.find('.renderer')
    canvas.attr
      width: @width
      height: @height

    c = canvas[0].getContext('2d')
    viewer.append(wndw)

    c.moveTo(50, 50)
    c.lineTo(200, 200)
    c.stroke()

swing.Frame = Frame
