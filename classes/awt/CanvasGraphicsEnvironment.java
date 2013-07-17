package classes.awt;

import java.awt.*;
import java.awt.image.BufferedImage;
import sun.awt.*;
import sun.java2d.*;

public class CanvasGraphicsEnvironment extends SunGraphicsEnvironment {
    // public native GraphicsDevice[] getScreenDevices()
    //     throws HeadlessException;

    // public native GraphicsDevice getDefaultScreenDevice()
    //     throws HeadlessException {

    // }

    public Graphics2D createGraphics(BufferedImage img){
        return new DoppioGraphics();
    }

    public native Font[] getAllFonts();

    public native String[] getAvailableFontFamilyNames();

    protected int getNumScreens() { return 1; }

    protected GraphicsDevice makeScreenDevice(int screennum) {
        return new DoppioGraphicsDevice(screennum);
    }

    protected FontConfiguration createFontConfiguration(){
        return new DoppioFontConfiguration(this);
    }

    @Override
    public FontConfiguration createFontConfiguration(
        boolean preferLocaleFonts, boolean preferPropFonts) {
        return createFontConfiguration();
    }

    public boolean isDisplayLocal() { return true; }
}
