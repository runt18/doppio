"use strict"

# Create a global namespace for all the Swing classes
window.swing or= {
  containers: {}
}

# Store a hash Underscore template functions used to render new Swing Components
# to the DOM, precompiled for performance.
$(->
  swing.templates = {}
  for s in ['window', 'icon']
    swing.templates[s] = _.template($("##{s}-tmpl").html())
)

# A button in the Taskbar that is associated with one Swing Container or
# subclass such as Window or Frame.
class swing.Icon
  constructor: (@container) ->
    @tmpl = swing.templates.icon
    @el = $(@tmpl({title: @container.title}))
    # Bring this icon's container to the front when clicked
    @el.click(=> @container.bring_to_front())

# A visual representation of all Swing Containers in the current session
class swing.Taskbar
  constructor: ->
    # XXX Workaround:

    # The taskbar must be initialized with at least one icon, due to a bug in
    # jQuery UI where empty lists are assumed to be verical. This dummy element
    # is then removed in make_sortable.

    # See:
    #   - http://bugs.jqueryui.com/ticket/7498
    #   - http://bugs.jqueryui.com/ticket/6702

    @el = $('<ul id="taskbar"><li class="icon">dummy</li></ul>')
    @make_sortable()

  # Use jQuery UI to make icons in the taskbar sortable
  make_sortable: ->
    @el.sortable(
      axis: 'x'
      containment: 'parent'
    ).disableSelection()
    # Remove the workaround dummy element
    @el.empty()

  render: ->
    $('#viewer').append(@el)

# Backs the Swing class Frame, a Window with a title and a border
class swing.Frame
  constructor: (@title='untitled', @height=0, @width=0) ->
    frame = this
    @id = "#{Date.now()}"
    # Get the template function for this class
    @tmpl = swing.templates.window
    # Use it to render the element
    @el = $(@tmpl({title: @title}))
    # Make it draggable with jQuery UI
    @el.draggable(
      handle: '.title'
      containment: 'parent'
      stack: '.swing-window'
    )
    # And resizable
    .resizable()
    # Give it a unique ID
    .attr('id', "frame-#{@id}")
    # Bind an event to the close button to remove this frame and its icon
    .find('.close').click(=>
      frame.el.remove()
      delete swing.containers[frame.id]
      frame.icon.el.remove()
    )

    # Get a reference to the rendering context use to draw this Frame's child
    # Components.
    @canvas = @el.find('.renderer')
    @canvas.attr
      width: @width
      height: @height
    @ctx = @canvas[0].getContext('2d')

    swing.containers[@id] = this
    @icon = new swing.Icon(this)

  bring_to_front: ->
    $('.swing-window').css({'z-index': 10})
    @el.css({'z-index': 100})

  render: ->
    $('#desktop').append(@el)
    swing.taskbar.el.append(@icon.el)

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

# Taskbar is a singleton -- there's only one in any given session
swing.taskbar = new swing.Taskbar()
