// Test case demonstrating adding a simple component (a text label)
// to a window

package classes.special_test.graphics;

import java.awt.Frame;
import java.awt.Label;

public class LabelTest {
    public static void main(String[] args) {
        Frame window = new Frame();

        window.setTitle("Label test");

        Label label = new Label("Hello world!");
        window.add(label);

        window.setVisible(true);
    }
}
