package classes.awt;

import java.awt.*;
import java.awt.datatransfer.Clipboard;
import java.awt.dnd.DragGestureEvent;
import java.awt.dnd.InvalidDnDOperationException;
import java.awt.dnd.peer.DragSourceContextPeer;
import java.awt.font.TextAttribute;
import java.awt.im.InputMethodHighlight;
import java.awt.image.ColorModel;
import java.awt.image.ImageObserver;
import java.awt.image.ImageProducer;
import java.awt.peer.*;
import java.net.URL;
import java.util.Map;
import java.util.Properties;

public class DoppioToolkit extends Toolkit {

    @Override
    protected DesktopPeer createDesktopPeer(Desktop desktop) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected ButtonPeer createButton(Button button) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected TextFieldPeer createTextField(TextField textField) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected LabelPeer createLabel(Label label) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected ListPeer createList(List list) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected CheckboxPeer createCheckbox(Checkbox checkbox) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected ScrollbarPeer createScrollbar(Scrollbar scrollbar) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected ScrollPanePeer createScrollPane(ScrollPane scrollPane) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected TextAreaPeer createTextArea(TextArea textArea) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected ChoicePeer createChoice(Choice choice) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected FramePeer createFrame(Frame frame) throws HeadlessException {
        return new DoppioFramePeer();
    }

    @Override
    protected CanvasPeer createCanvas(Canvas canvas) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected PanelPeer createPanel(Panel panel) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected WindowPeer createWindow(Window window) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected DialogPeer createDialog(Dialog dialog) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected MenuBarPeer createMenuBar(MenuBar menuBar) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected MenuPeer createMenu(Menu menu) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected PopupMenuPeer createPopupMenu(PopupMenu popupMenu) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected MenuItemPeer createMenuItem(MenuItem menuItem) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected FileDialogPeer createFileDialog(FileDialog fileDialog) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected CheckboxMenuItemPeer createCheckboxMenuItem(CheckboxMenuItem checkboxMenuItem) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected FontPeer getFontPeer(String s, int i) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Dimension getScreenSize() throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public int getScreenResolution() throws HeadlessException {
        return 0;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public ColorModel getColorModel() throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public String[] getFontList() {
        return new String[0];  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public FontMetrics getFontMetrics(Font font) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void sync() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image getImage(String s) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image getImage(URL url) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image createImage(String s) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image createImage(URL url) {
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
    public Image createImage(ImageProducer imageProducer) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Image createImage(byte[] bytes, int i, int i2) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public PrintJob getPrintJob(Frame frame, String s, Properties properties) {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void beep() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Clipboard getSystemClipboard() throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    protected EventQueue getSystemEventQueueImpl() {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public DragSourceContextPeer createDragSourceContextPeer(DragGestureEvent dragGestureEvent) throws InvalidDnDOperationException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isModalityTypeSupported(Dialog.ModalityType modalityType) {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isModalExclusionTypeSupported(Dialog.ModalExclusionType modalExclusionType) {
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public Map<TextAttribute, ?> mapInputMethodHighlight(InputMethodHighlight inputMethodHighlight) throws HeadlessException {
        return null;  //To change body of implemented methods use File | Settings | File Templates.
    }
}
