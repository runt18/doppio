trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        _this.get_field(rs, 'Ljava/awt/Component;peer').domPeer.render()
    )
]
