# A button in the Taskbar that is associated with one Swing Container or
# subclass such as Window or Frame.
class swing.Icon
  constructor: (@container) ->
    @tmpl = swing.templates.icon
    @el = $(@tmpl({title: @container.title}))
    # Bring this icon's container to the front when clicked
    @el.click(=> @container.bring_to_front())
