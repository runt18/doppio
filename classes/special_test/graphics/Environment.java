package classes.special_test.graphics;

import java.awt.*;

public class Environment {
    public static void main(String[] args){
        GraphicsConfiguration ge = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
        System.out.println(ge);
    }
}
