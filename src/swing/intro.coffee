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
