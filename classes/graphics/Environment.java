package classes.special_test.graphics;

import java.awt.*;

public class Environment {
    public static void main(String[] args){
        GraphicsConfiguration gc = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
        System.out.println(gc);
    }
}
