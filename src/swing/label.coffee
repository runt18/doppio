# Backs the Swing class Label, a Component for displaying a single line of text
class swing.Label
  constructor: (@parent=null, @value='', @height=0, @width=0) ->

  # Render this Component to its parent Container
  render: ->
    {ctx} = @parent
    ctx.beginPath()
    ctx.rect(0, 0, @width, @height)
    ctx.stroke()
    ctx.fillText(@value, 0, @height)
