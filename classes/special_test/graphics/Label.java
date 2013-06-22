// Test case demonstrating adding a simple component (a text label)
// to a window

package classes.special_test.graphics;

import javax.swing.SwingUtilities;
import javax.swing.JFrame;
import javax.swing.JLabel;

public class Label implements Runnable {
    public static void main(String[] args) {
        Label main = new Label();
        SwingUtilities.invokeLater(main);
    }

    public void run(){
        JFrame window = new JFrame();

        window.setTitle("Label test");
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Hello world!");
        window.add(label);

        window.pack();
        window.setLocationByPlatform(true);
        window.setVisible(true);
    }
}
