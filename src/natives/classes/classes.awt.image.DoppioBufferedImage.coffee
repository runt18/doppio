trapped_methods.java.awt.image.BufferedImage = [
  o('getRGB(II)I', (rs, _this, x, y) ->
    # Returns the rgba colour of the pixel at the given x, y coordinates on
    # the canvas as an integer

    # Get the colour as an array of [red, green, blue, alpha] values
    # between 0 and 255 inclusive
    {data: [red, green, blue, alpha]} = window.context.getImageData(x, y, 1, 1)
    # Convert to a 32-bit integer with the bitstring
    # AAAA AAAA RRRR RRRR GGGG GGGG BBBB BBBB
    colour = (alpha << 24) | (red << 16) | (green << 8) | (blue << 0)

    return colour
  )
]
