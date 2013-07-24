// Test case demonstrating adding a simple component (a text label)
// to a window

package classes.graphics;

import java.awt.Frame;
import java.awt.Label;

public class LabelTest {
    public static void main(String[] args) {
        Frame window = new Frame();

        window.setTitle("Label test");

        Label label = new Label("Hello world!");
        window.add(label);

        // Call pack to calculate frame size
        window.pack();
        // Manually trigger the paint method
        window.paint(window.getGraphics());
        window.setVisible(true);
    }
}
