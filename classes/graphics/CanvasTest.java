// A test case demonstrating drawing arbitrary pixel data to a component

package classes.graphics;

import java.awt.Frame;
import java.awt.Canvas;
import java.awt.Graphics;
import java.awt.Dimension;

public class CanvasTest {
    public static void main(String[] args) {
        CanvasTest c = new CanvasTest();
        c.run();
    }

    public void run(){
        Frame window = new Frame();

        window.setTitle("Canvas test");

        CustomCanvas canvas = new CustomCanvas();
        window.add(canvas);

        window.pack();
        window.setVisible(true);
    }

    public class CustomCanvas extends Canvas {
        public CustomCanvas(){
            setPreferredSize(new Dimension(200, 200));
        }

        @Override
        public void paint(Graphics g) {
            g.drawLine(50, 50, 150, 150);
        }
    }
}
