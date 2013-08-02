# Backs the Swing class Frame, a Window with a title and a border
class swing.Frame extends swing.Window
  constructor: (@title='untitled', @size={height: 0, width: 0}, @position={left: 0, top: 0}) ->
    # Save a reference to this object for reference from child elements
    frame = this
    @id = "#{Date.now()}"
    # Get a DOM element for this component by rendering the template
    @el = @template()
    # Make it draggable with jQuery UI
    @el.draggable(
      handle: '.title'
      containment: 'parent'
      stack: '.swing-window'
    )
    # And resizable
    .resizable(
      containment: 'parent'
    )
    .css(@position)
    # Give it a unique ID
    .attr('id', "frame-#{@id}")
    # Bind an event to the close button to remove this frame and its icon
    .find('.close').click(=>
      frame.el.remove()
      delete swing.containers[frame.id]
      frame.icon.el.remove()
    )

    @init_renderer()

    swing.containers[@id] = this
    @icon = new swing.Icon(this)

  template: -> $(swing.templates.window({title: @title}))

  # Get a reference to the rendering context use to draw this Frame's child
  # Components.
  init_renderer: ->
    @canvas = @el.find('.renderer')
    @canvas.attr(@size)
    @ctx = @canvas[0].getContext('2d')

  bring_to_front: ->
    $('.swing-window').css({'z-index': 10})
    @el.css({'z-index': 100})

  render: ->
    $('#desktop').append(@el)
    @el.trigger('start')
    swing.taskbar.el.append(@icon.el)
