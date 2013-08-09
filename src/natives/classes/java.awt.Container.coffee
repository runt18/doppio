trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        c.render() for c of swing.containers
    )
]
