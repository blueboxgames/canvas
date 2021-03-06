package ir.grantech.canvas.controls.groups;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.utils.DisplayObjectRecycler;
import ir.grantech.canvas.controls.groups.sections.CanSection;
import ir.grantech.canvas.controls.items.MenuItemRenderer;
import ir.grantech.canvas.events.CanEvent;
import ir.grantech.canvas.services.Configs.Config;
import ir.grantech.canvas.themes.CanTheme;
import motion.Actuate;
import openfl.events.Event;
import openfl.events.MouseEvent;

class Menu extends CanSection {
	public var isOpen:Bool;

	private var primaryList:ListView;
	private var secondaryPanel:LayoutGroup;
	private var secondaryTitle:Label;
	private var secondaryList:ListView;

	@:access(ir.grantech.canvas.themes.CanTheme)
	override private function initialize() {
		var skin = new Button();
		skin.addEventListener(MouseEvent.MOUSE_DOWN, this.skin_mouseDownHandler);
		this.backgroundSkin = skin;

		this.visible = false;
		this.layout = new AnchorLayout();

		// primary list
		var border = CanTheme.DPI;
		this.primaryList = this.createList(configs.menuData, DisplayObjectRecycler.withClass(MenuItemRenderer), new AnchorLayoutData(0, null, 0));
		this.primaryList.width = 140 * CanTheme.DPI;
		this.primaryList.itemToText = this.menuItemToText;
		this.primaryList.addEventListener(CanEvent.ITEM_HOVER, this.primaryList_hoverHandler);
		this.primaryList.addEventListener(CanEvent.ITEM_SELECT, this.lists_selectHandler);

		var theme = Std.downcast(Theme.getTheme(), CanTheme);
		var listSkin = new RectangleSkin();
		listSkin.fill = theme.getContainerFill();
		listSkin.border = LineStyle.SolidColor(border, theme.dividerColor);
		this.primaryList.backgroundSkin = listSkin;

		var listLayout = new VerticalListLayout();
		listLayout.paddingRight = border;
		this.primaryList.layout = listLayout;

		// second list
		this.secondaryPanel = new LayoutGroup();
		this.secondaryPanel.layout = new AnchorLayout();
		this.secondaryPanel.width = 140 * CanTheme.DPI;
		this.secondaryPanel.layoutData = new AnchorLayoutData(-border, null, -border, this.primaryList.width);
		this.secondaryPanel.visible = false;
		this.addChild(this.secondaryPanel);

		var panelSkin = new RectangleSkin();
		panelSkin.fill = theme.getContainerFill();
		panelSkin.border = LineStyle.SolidColor(border, theme.dividerColor);
		this.secondaryPanel.backgroundSkin = panelSkin;

		this.secondaryTitle = new Label();
		this.secondaryTitle.embedFonts = true;
		this.secondaryTitle.variant = Label.VARIANT_HEADING;
		this.secondaryTitle.layoutData = new AnchorLayoutData(padding, padding, null, padding);
		this.secondaryPanel.addChild(this.secondaryTitle);

		this.secondaryList = new ListView();
		this.secondaryList.itemRendererRecycler = DisplayObjectRecycler.withClass(MenuItemRenderer);
		this.secondaryList.layoutData = new AnchorLayoutData(CanTheme.DPI * 24, border, 0, border);
		this.secondaryList.itemToText = this.menuItemToText;
		this.secondaryList.addEventListener(CanEvent.ITEM_SELECT, this.lists_selectHandler);
		this.secondaryList.backgroundSkin = null;
		this.secondaryPanel.addChild(this.secondaryList);
	}

	private function menuItemToText(item:Config):String {
		return item.name;
	}

	private function lists_selectHandler(event:CanEvent):Void {
		var itemRenderer = cast(event.target, MenuItemRenderer);
		#if desktop
		if (itemRenderer.menuData.path != null) {
			doc.open(itemRenderer.menuData.path);
			this.close();
			return;
		}
		#end
		switch (itemRenderer.menuData.name) {
			case "New":
				doc.close();
			case "Open...":
				doc.openAs();
			case "Save":
				doc.save(false);
			case "Save as...":
				doc.save(true);
			case "Import":
				libs.open();
		}

		this.close();
	}

	private function primaryList_hoverHandler(event:CanEvent):Void {
		var itemRenderer = cast(event.target, MenuItemRenderer);
		this.secondaryPanel.visible = event.data;
		if (event.data) {
			this.secondaryTitle.text = itemRenderer.menuData.name.toUpperCase();
			this.secondaryList.dataProvider = new ArrayCollection(itemRenderer.menuData.children);
		}
	}

	public function toggle():Void {
		if (this.isOpen)
			this.close();
		else
			this.open();
	}

	public function open() {
		this.isOpen = true;
		this.visible = true;
		this.parent.addChild(this);
		Actuate.stop(this);
		Actuate.tween(this, 0.4, {x: 0});
	}

	public function close() {
		this.primaryList.selectedItem = null;
		this.secondaryList.selectedItem = null;
		this.secondaryPanel.visible = false;
		Actuate.stop(this);
		Actuate.tween(this, 0.4, {x: -this.primaryList.width}).onComplete((?p:Array<Dynamic>) -> {
			this.isOpen = false;
			this.visible = false;
		});
	}

	private function skin_mouseDownHandler(event:Event):Void {
		this.close();
	}
}
