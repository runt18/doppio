package classes.awt;

import java.awt.*;
import java.awt.im.InputMethodRequests;
import java.awt.peer.TextComponentPeer;

public class DoppioTextComponentPeer extends DoppioComponentPeer implements TextComponentPeer {

    @Override
    public void setEditable(boolean b) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public String getText() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setText(String s) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int getSelectionStart() {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int getSelectionEnd() {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void select(int i, int i2) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setCaretPosition(int i) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int getCaretPosition() {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int getIndexAtPoint(int i, int i2) {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Rectangle getCharacterBounds(int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public long filterEvents(long l) {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public InputMethodRequests getInputMethodRequests() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }
}
