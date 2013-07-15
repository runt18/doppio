// A test case demonstrating drawing arbitrary pixel data to a component

package classes.graphics;

import javax.swing.SwingUtilities;
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Dimension;

public class Canvas implements Runnable {
    public static void main(String[] args) {
        Canvas main = new Canvas();
        SwingUtilities.invokeLater(main);
    }

    public void run(){
        JFrame window = new JFrame();

        window.setTitle("Canvas test");
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        CustomPanel panel = new CustomPanel();
        window.add(panel);

        window.pack();
        window.setLocationByPlatform(true);
        window.setVisible(true);
    }

    public class CustomPanel extends JPanel {
        public CustomPanel(){
            setPreferredSize(new Dimension(200, 200));
        }

        @Override
        public void paintComponent(Graphics g) {
            super.paintComponent(g);
            Graphics2D g2 = (Graphics2D) g;
            g2.drawLine(50, 50, 150, 150);
        }
    }
}
