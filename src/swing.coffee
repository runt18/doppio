"use strict"

window.swing or= {}

class Frame
  constructor: (@title='untitled') ->

  render: ->
    wndw = $(_.template($('#window-tmpl').html(), {title: @title}))
    viewer = $('#viewer')
    canvas = wndw.find('.renderer')
    c = canvas[0].getContext('2d')
    viewer.width(canvas.attr('width'))
    viewer.append(wndw)

    c.moveTo(50, 50)
    c.lineTo(200, 200)
    c.stroke()

swing.Frame = Frame
