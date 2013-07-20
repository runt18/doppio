package classes.graphics;

import java.awt.*;
import java.awt.image.BufferedImage;

public class BITest {
    public static void main(String[] args){
        BufferedImage image = new BufferedImage(600, 400, BufferedImage.TYPE_INT_RGB);
        Graphics g = image.getGraphics();
        Graphics2D g2 = (Graphics2D) g;
        g2.drawString("Test", 10, 10);
        System.out.println(image.getRGB(100, 100));
    }
}
