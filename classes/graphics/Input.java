// Test case demonstrating a component that can react to user input
// (a text field) and adding custom events to a component

package classes.graphics;

import javax.swing.SwingUtilities;
import javax.swing.JFrame;
import javax.swing.JTextField;
import javax.swing.JLabel;
import javax.swing.Box;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Input implements Runnable {
    private JLabel l;
    private JTextField tf;

    public static void main(String[] args) {
        Input main = new Input();
        SwingUtilities.invokeLater(main);
    }

    public void run(){
        JFrame window = new JFrame();

        window.setTitle("Input test");
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        String sample = "Hello";

        tf = new JTextField(sample);
        l = new JLabel(sample.length() + " characters.");

        tf.addActionListener(new LabelUpdater());

        Box wrapper = Box.createVerticalBox();

        wrapper.add(tf);
        wrapper.add(l);

        window.add(wrapper);

        window.pack();
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
