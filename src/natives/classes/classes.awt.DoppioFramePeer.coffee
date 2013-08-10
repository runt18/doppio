native_methods.classes.awt.DoppioFramePeer = [
    o('createDOMElement()V', (rs, _this) ->
        console.log('frame', _this)
        frame = _this.get_field(rs, 'Lclasses/awt/DoppioFramePeer;frame')

        title = frame.get_field(rs, 'Ljava/awt/Frame;title').jvm2js_str()

        size =
            height: frame.get_field(rs, keys.height)
            width:  frame.get_field(rs, keys.width)

        # children = _this.get_field(rs, 'Ljava/awt/Container;component').get_field(rs, 'Ljava/util/ArrayList;elementData').array

        _this.domPeer = new swing.Frame(title, size, {top: 0, left: 0})
    )
]
