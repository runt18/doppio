g2d_sig = 'Ljava/awt/Graphics2D;'
bi_sig = 'Ljava/awt/image/BufferedImage;'
native_methods.classes.awt.CanvasGraphicsEnvironment = [
  # TODO: implement this
  #o 'createFontConfiguration()Lsun/awt/FontConfiguration;', (rs) ->

  o("createGraphics(#{bi_sig})#{g2d_sig}", (rs, _this) ->
    # The callback called if the Graphics2D class is successfully loaded
    success1 = (g2d_cls) ->
      # Get the constructor from the class
      cons = g2d_cls.get_method('<init>()V')
      # If the constructor fails to run, call an exception callback
      except3 = (e, success2, except2) -> except2(e)
      # If the constructor succeeds, call the success callback with the newly
      # instantiated Graphics2D object
      success4 = (g2d, success3, except4) -> success3(g2d)
      # The constructor takes no arguments
      args = []
      # Call the constructor
      success2(rs.call_bytecode(g2d_cls, cons, args, success4, except3))

    # Start an asynchronous operation
    rs.async_op (resume_cb) ->
      # Get the classloader and use it to load and initialize the Graphics2D
      # class
      rs.get_cl().initialize_class(rs, g2d_sig, success1, except1)
      resume_cb()

    # Get the Graphics2D class
    # g2d_cls = rs.get_bs_class(g2d_sig)



  )
]

