keys =
    height: 'Ljava/awt/Component;height'
    width: 'Ljava/awt/Component;width'
    value: 'Ljava/lang/String;value'
    parent: 'Ljava/awt/Component;parent'

native_methods.classes.awt.DoppioLabelPeer = [
    o('createDOMElement()V', (rs, _this) ->
        console.log('createDOMElement')
        console.log(_this)

        value = _this.get_field(rs, 'Ljava/awt/Label;text').jvm2js_str()
        height = _this.get_field(rs, keys.height)
        width = _this.get_field(rs, keys.width)
        parent = _this.get_field(rs, keys.parent).domPeer

        swing.components.push(new swing.Label(parent, value, height, width))
    )

    o('getPreferredWidth()I', (rs, _this) ->
        return 18
    )

    o('getPreferredHeight()I', (rs, _this) ->
        return 42
    )
]
