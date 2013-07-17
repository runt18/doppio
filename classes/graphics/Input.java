// Test case demonstrating a component that can react to user input
// (a text field) and adding custom events to a component

package classes.graphics;

import java.awt.Frame;
import java.awt.TextField;
import java.awt.Label;
import java.awt.GridLayout;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Input {
    private Label l;
    private TextField tf;

    public static void main(String[] args) {
        Input i = new Input();
        i.run();
    }

    public void run(){
        Frame window = new Frame();

        window.setTitle("Input test");

        String sample = "Hello";

        tf = new TextField(sample);
        l = new Label(sample.length() + " characters.");

        tf.addActionListener(new LabelUpdater());

        window.setLayout(new GridLayout(1, 2));

        window.add(tf);
        window.add(l);

        window.setLocationByPlatform(true);
        window.setVisible(true);
    }

    private class LabelUpdater implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent event){
            l.setText(tf.getText().length() + " characters.");
        }
    }
}
