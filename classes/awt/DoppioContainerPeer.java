package classes.awt;

import java.awt.*;
import java.awt.peer.ContainerPeer;

public class DoppioContainerPeer extends DoppioComponentPeer implements ContainerPeer {

    @Override
    public Insets getInsets() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void beginValidate() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void endValidate() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void beginLayout() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void endLayout() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isPaintPending() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void restack() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isRestackSupported() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Insets insets() {
        return new Insets(0, 0, 0, 0);
    }
}
