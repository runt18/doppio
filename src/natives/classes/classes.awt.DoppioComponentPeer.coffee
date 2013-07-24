trapped_methods.java.awt.Container = [
    o('paint(Ljava/awt/Graphics;)V', (rs, _this, graphics) ->
        {fields} = _this
        title_arr = fields['Ljava/awt/Frame;title'].fields['Ljava/lang/String;value'].array
        title_str = (String.fromCharCode(code) for code in title_arr).join('')
        console.log(_this)
        console.log(title_str)
        console.log(graphics)

        {Frame} = require('./swing')
        f = new Frame(title_str)
        f.render()
    )
]
