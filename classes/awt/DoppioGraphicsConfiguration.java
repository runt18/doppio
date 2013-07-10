package classes.awt;

import classes.awt.DoppioGraphicsDevice;

import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;

public class DoppioGraphicsConfiguration extends GraphicsConfiguration {
    private DoppioGraphicsDevice device;


    public DoppioGraphicsConfiguration(DoppioGraphicsDevice device){
        this.device = device;
    }

    @Override
    public GraphicsDevice getDevice() {
        return device;
    }

    @Override
    public BufferedImage createCompatibleImage(int i, int i2) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public ColorModel getColorModel() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public ColorModel getColorModel(int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public AffineTransform getDefaultTransform() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public AffineTransform getNormalizingTransform() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Rectangle getBounds() {
        return new Rectangle(0, 0, 100, 100);
    }
}
