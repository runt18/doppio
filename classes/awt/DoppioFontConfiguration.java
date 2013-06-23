package classes.awt;

import sun.awt.FontConfiguration;
import sun.java2d.SunGraphicsEnvironment;

import java.nio.charset.Charset;

public class DoppioFontConfiguration extends FontConfiguration {

    public DoppioFontConfiguration(SunGraphicsEnvironment sunGraphicsEnvironment) {
        super(sunGraphicsEnvironment);
    }

    @Override
    public String getExtraFontPath() {
        return "test";
    }

    @Override
    protected String getFileNameFromComponentFontName(String componentFontName){
        return "test";
    }

    @Override
    protected String getFaceNameFromComponentFontName(String componentFontName){
        return "test";
    }

    protected Charset getDefaultFontCharset(String fontName){
        return null;
    }

    protected String getEncoding(String awtFontName, String characterSubsetName){
        return "test";
    }

    protected void initReorderMap(){

    }

    public String getFallbackFamilyName(String fontName, String defaultFallback){
        return "test";
    }

}
