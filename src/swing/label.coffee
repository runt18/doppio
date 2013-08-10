# Backs the Swing class Label, a Component for displaying a single line of text
class swing.Label
  constructor: (@parent=null, @value='', @height=0, @width=0) ->
    @font_size = 12

  # Render this Component to its parent Container
  render: ->
    {ctx} = @parent
    ctx.beginPath()
    ctx.rect(0, 0, @width, @height)
    ctx.stroke()

    @set_font()
    ctx.fillText(@value, 0, @height)

  # Call this before any text operation to ensure that the rendering context's
  # configuration is in sync with this object
  set_font: ->
    @parent.ctx.font = "#{@font_size}px sans-serif"

  calc_width: ->
    @set_font()
    {width} = @parent.ctx.measureText(@value)
    return width

  calc_height: -> @font_size

  calc_size: -> {
    width: @calc_width()
    height: @calc_height()
  }
