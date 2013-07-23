native_methods.classes.awt.DoppioGraphics = [
    o('drawString(Ljava/lang/String;IILjava/lang/Object;)V', (rs, _this, string, x, y, n) ->
        # XXX: Don't hardcode these - get them from the parent Image/Component's
        # properties somehow
        width = 80
        height = 24
        font_size = 16

        canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height

        # XXX: Don't make this global
        window.context = canvas.getContext('2d')
        context.font = "#{font_size}pt Arial"

        context.beginPath()
        context.rect(0, 0, width, height)
        context.fillStyle = 'black'
        context.fill()

        context.fillStyle = 'white'
        context.fillText(string.jvm2js_str(), x, y)
    )
]
