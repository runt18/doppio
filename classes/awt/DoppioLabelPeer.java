package classes.awt;

import java.awt.peer.LabelPeer;
import java.awt.Toolkit;
import java.awt.Dimension;

public class DoppioLabelPeer extends DoppioComponentPeer implements LabelPeer {

    public DoppioLabelPeer(){
        super();
        createDOMElement();
    }

    private native int getPreferredWidth();

    private native int getPreferredHeight();

    private native void createDOMElement();

    @Override
    public Dimension getPreferredSize(){
        return new Dimension(getPreferredWidth(), getPreferredHeight());
    }

    @Override
    public void setText(String s) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setAlignment(int i) {
        //To change body of implemented methods use File | Settings | File Templates.
    }
}
