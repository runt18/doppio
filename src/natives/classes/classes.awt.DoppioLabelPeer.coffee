keys =
    height: 'Ljava/awt/Component;height'
    width: 'Ljava/awt/Component;width'
    value: 'Ljava/lang/String;value'
    parent: 'Ljava/awt/Component;parent'

native_methods.classes.awt.DoppioLabelPeer = [
    o('createDOMElement()V', (rs, _this) ->
        console.log('createDOMElement')
        console.log(_this)

        label = _this.get_field(rs, 'Lclasses/awt/DoppioLabelPeer;label')
        value = label.get_field(rs, 'Ljava/awt/Label;text').jvm2js_str()
        height = label.get_field(rs, keys.height)
        width = label.get_field(rs, keys.width)
        parent = label.get_field(rs, keys.parent).get_field(rs, 'Ljava/awt/Component;peer').domPeer

        _this.domPeer = new swing.Label(parent, value, height, width)
    )

    o('getPreferredWidth()I', (rs, _this) ->
        return _this.domPeer.calc_width()
    )

    o('getPreferredHeight()I', (rs, _this) ->
        return _this.domPeer.calc_height()
    )
]
