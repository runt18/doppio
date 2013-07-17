package classes.awt;

import java.awt.*;
import java.awt.peer.TextFieldPeer;

public class DoppioTextFieldPeer extends DoppioTextComponentPeer implements TextFieldPeer {

    @Override
    public void setEchoChar(char c) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Dimension getPreferredSize(int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Dimension getMinimumSize(int i) {
        return new Dimension(10, 10);
    }

    @Override
    public void setEchoCharacter(char c) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Dimension preferredSize(int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Dimension minimumSize(int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }
}
