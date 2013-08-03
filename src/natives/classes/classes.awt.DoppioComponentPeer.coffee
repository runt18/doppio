keys =
    height: 'Ljava/awt/Component;height'
    width: 'Ljava/awt/Component;width'
    value: 'Ljava/lang/String;value'

trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        {Frame, Label} = require('./swing')

        title_str = _this.get_field(rs, 'Ljava/awt/Frame;title').jvm2js_str()

        size =
            height: _this.get_field(rs, keys.height)
            width:  _this.get_field(rs, keys.width)

        children = _this.get_field(rs, 'Ljava/awt/Container;component').get_field(rs, 'Ljava/util/ArrayList;elementData').array

        f = new Frame(title_str, size, {top: 0, left: 0})
        components = [f]

        for component in children when component isnt null
            console.log(component)
            switch component.cls.this_class
                when 'Ljava/awt/Label;'
                    value = component.get_field(rs, 'Ljava/awt/Label;text').jvm2js_str()

                    height = component.get_field(rs, keys.height)
                    width = component.get_field(rs, keys.width)

                    components.push(new Label(f, value, height, width))

        c.render() for c in components
    )
]
