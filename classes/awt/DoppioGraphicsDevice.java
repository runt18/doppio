package classes.awt;

import classes.awt.DoppioGraphicsConfiguration;

import java.awt.*;

public class DoppioGraphicsDevice extends GraphicsDevice {
    private int screen;
    GraphicsConfiguration[] configs;

    public DoppioGraphicsDevice(int screennum){
        this.screen = screennum;
    }

    @Override
    public int getType() {
        return 0;
    }

    @Override
    public String getIDstring() {
        return null;
    }

    @Override
    public GraphicsConfiguration[] getConfigurations() {
        if (this.configs == null) {
            this.makeConfigurations();
        }
        return this.configs;
    }

    @Override
    public GraphicsConfiguration getDefaultConfiguration() {
        return getConfigurations()[0];
    }

    public int getNumConfigs(int screen){
        return 1;
    }

    private void makeConfigurations() {
        int num = getNumConfigs(screen);
        this.configs = new GraphicsConfiguration[num];
        this.configs[0] = new DoppioGraphicsConfiguration(this);
    }
}
