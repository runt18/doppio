package classes.graphics;

import sun.awt.FontConfiguration;
import classes.awt.CanvasGraphicsEnvironment;

public class FontConfig {
    public static void main(String[] args){
        CanvasGraphicsEnvironment ge =
            (CanvasGraphicsEnvironment) CanvasGraphicsEnvironment.getLocalGraphicsEnvironment();

        FontConfiguration fc = ge.createFontConfiguration(true, true);
    }
}
