trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        {fields} = _this

        title_arr = fields['Ljava/awt/Frame;title'].fields['Ljava/lang/String;value'].array
        title_str = (String.fromCharCode(code) for code in title_arr).join('')

        height = fields['Ljava/awt/Component;height']
        width = fields['Ljava/awt/Component;width']

        get_comp = _this.get_method('getComponent(I)Ljava/awt/Component;')

        console.log(_this)
        console.log(title_str)
        console.log(graphics)

        {Frame} = require('./swing')
        f = new Frame(title_str, height, width)
        f.render()
    )
]
