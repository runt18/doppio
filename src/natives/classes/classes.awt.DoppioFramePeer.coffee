native_methods.classes.awt.DoppioFramePeer = [
    o('createDOMElement()V', (rs, _this) ->
        title_str = ''# _this.get_field(rs, 'Ljava/awt/Frame;title').jvm2js_str()

        size =
            height: 0#_this.get_field(rs, keys.height)
            width:  0#_this.get_field(rs, keys.width)

        # children = _this.get_field(rs, 'Ljava/awt/Container;component').get_field(rs, 'Ljava/util/ArrayList;elementData').array

        _this.domPeer = new swing.Frame(title_str, size, {top: 0, left: 0})
    )
]
