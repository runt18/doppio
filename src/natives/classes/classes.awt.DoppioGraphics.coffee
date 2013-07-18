native_methods.classes.awt.DoppioGraphics = [
    o('drawString(Ljava/lang/String;IILjava/lang/Object;)V', (rs, _this, string, x, y, n) ->
        canvas = document.createElement('canvas')
        context = canvas.getContext('2d')
        context.fillText(string, x, y)

        # Returns the rgba colour of the pixel at the given x, y coordinates on
        #the canvas as an integer
        getPixel = (x, y) ->
            # Get the colour as an array of [red, green, blue, alpha] values
            # between 0 and 255 inclusive
            {data: [red, green, blue, alpha]} = context.getImageData(x, y, 1, 1)
            # Convert to an integer
            colour = (alpha << 24) | (red << 16) | (green << 8) | (blue << 0)

            return colour

        console.log(getPixel(10, 10))
    )
]
