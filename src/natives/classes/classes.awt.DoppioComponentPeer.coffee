arr_to_str = (a) -> (String.fromCharCode(c) for c in a).join('')

keys =
    height: 'Ljava/awt/Component;height'
    width: 'Ljava/awt/Component;width'
    value: 'Ljava/lang/String;value'

trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        {Frame, Label} = require('./swing')
        {fields} = _this
        console.log(_this)

        title_arr = fields['Ljava/awt/Frame;title'].fields[keys.value].array
        title_str = arr_to_str(title_arr)

        height = fields[keys.height]
        width = fields[keys.width]

        children = fields['Ljava/awt/Container;component'].fields['Ljava/util/ArrayList;elementData'].array

        console.log(children)

        f = new Frame(title_str, height, width)
        components = [f]

        for component in children when component isnt null
            console.log(component)
            switch component.cls.this_class
                when 'Ljava/awt/Label;'
                    value_arr = component.fields['Ljava/awt/Label;text'].fields[keys.value].array
                    value = arr_to_str(value_arr)

                    height = component.fields[keys.height]
                    width = component.fields[keys.width]

                    components.push(new Label(f, value, height, width))

        c.render() for c in components

        swing.taskbar.update()
    )
]
