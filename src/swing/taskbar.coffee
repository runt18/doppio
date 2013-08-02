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

# Taskbar is a singleton -- there's only one in any given session
swing.taskbar = new swing.Taskbar()
