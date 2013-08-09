package classes.awt;

import sun.awt.CausedFocusEvent;
import sun.java2d.pipe.Region;

import java.awt.*;
import java.awt.event.PaintEvent;
import java.awt.image.ColorModel;
import java.awt.image.ImageObserver;
import java.awt.image.ImageProducer;
import java.awt.image.VolatileImage;
import java.awt.peer.ComponentPeer;
import java.awt.peer.ContainerPeer;

public class DoppioComponentPeer implements ComponentPeer {

    @Override
    public boolean isObscured() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean canDetermineObscurity() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setVisible(boolean b) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setEnabled(boolean b) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void paint(Graphics graphics){

    }

    @Override
    public void repaint(long l, int i, int i2, int i3, int i4) {

    }

    @Override
    public void print(Graphics graphics) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setBounds(int i, int i2, int i3, int i4, int i5) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void handleEvent(AWTEvent awtEvent) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void coalescePaintEvent(PaintEvent paintEvent) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Point getLocationOnScreen() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    // Override with a native method in implementing classes to provide an actual size
    @Override
    public Dimension getPreferredSize() {
        return new Dimension(10, 10);
    }

    @Override
    public Dimension getMinimumSize() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public ColorModel getColorModel() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Toolkit getToolkit() {
        return new DoppioToolkit();
    }

    @Override
    public Graphics getGraphics() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public FontMetrics getFontMetrics(Font font) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void dispose() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setForeground(Color color) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setBackground(Color color) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void setFont(Font font) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void updateCursorImmediately() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean requestFocus(Component component, boolean b, boolean b2, long l, CausedFocusEvent.Cause cause) {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isFocusable() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image createImage(ImageProducer imageProducer) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image createImage(int i, int i2) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public VolatileImage createVolatileImage(int i, int i2) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean prepareImage(Image image, int i, int i2, ImageObserver imageObserver) {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int checkImage(Image image, int i, int i2, ImageObserver imageObserver) {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public GraphicsConfiguration getGraphicsConfiguration() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean handlesWheelScrolling() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void createBuffers(int i, BufferCapabilities bufferCapabilities) throws AWTException {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image getBackBuffer() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void flip(int i, int i2, int i3, int i4, BufferCapabilities.FlipContents flipContents) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void destroyBuffers() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void reparent(ContainerPeer containerPeer) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isReparentSupported() {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void layout() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Rectangle getBounds() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void applyShape(Region region) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    // Deprecated. Defers to getPreferredSize for the canonical implementation
    public Dimension preferredSize() {
        return getPreferredSize();
    }

    @Override
    public Dimension minimumSize() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void show() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void hide() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void enable() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void disable() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void reshape(int i, int i2, int i3, int i4) {
        //To change body of implemented methods use File | Settings | File Templates.
    }
}
