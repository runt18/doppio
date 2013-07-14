g2d_sig = 'Ljava/awt/Graphics2D;'
bi_sig = 'Ljava/awt/image/BufferedImage;'
cg_sig = "createGraphics(#{bi_sig})#{g2d_sig}"
native_methods.classes.awt.CanvasGraphicsEnvironment = [
  # TODO: implement this
  #o 'createFontConfiguration()Lsun/awt/FontConfiguration;', (rs) ->

  o(cg_sig,
    ((rs, _this) ->
      # Start an asynchronous operation
      rs.async_op(
        ((success, except) ->
          # Get the classloader and use it to load and initialize the Graphics2D
          # class
          rs.get_cl().initialize_class(rs, g2d_sig,
            ((g2d_cls) ->
              # Get the constructor from the class
              cons = g2d_cls.get_method('<init>()V')
              # If the constructor fails to run, call an exception callback
              except2 = (e, suc, exc) -> exc(e)
              # If the constructor succeeds, call the success callback with the newly
              # instantiated Graphics2D object
              success2 = (g2d, suc, exc) -> suc(g2d)
              # The constructor takes no arguments
              args = []
              # Call the constructor
              # XXX: uses the hack for calling call_bytecode from within an async_op
              except(-> success(rs.call_bytecode(g2d_cls, cons, args, success2, except2)))
            ),
            except
          )
        )
      )
    )
  )
]

