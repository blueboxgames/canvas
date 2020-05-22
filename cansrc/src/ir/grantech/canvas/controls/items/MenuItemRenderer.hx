package ir.grantech.canvas.controls.items;

import openfl.events.MouseEvent;
import feathers.controls.ListView;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.skins.BaseGraphicsPathSkin;
import feathers.skins.DividerSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import ir.grantech.canvas.events.CanEvent;
import ir.grantech.canvas.themes.CanTheme;
import ir.grantech.canvas.themes.ScaledBitmap;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class MenuItemRenderer extends ItemRenderer implements IDataRenderer {
	@:isVar
	public var data(get, set):Dynamic;

	@:access(Xml)
	private function set_data(value:Dynamic):Dynamic {
		if (this.data == value)
			return this.data;
		if (value == null)
			return value;
		this.data = value;
		this.menuData = cast(this.data, Xml);
		if (this.menuData.nodeName == "divider") {
			isDivider = true;
		} else {
			if (this.menuData.children.length == 0)
				this.shortKey = this.menuData.attributeMap["shortKey"];
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.data;
	}

	private function get_data():Dynamic {
		return this.data;
	}

	public var menuData:Xml;
	public var isDivider:Bool;
	public var shortKey:String;
	private var hintField:TextField;

	public function new() {
		super();
	}

	override private function initializeItemRendererTheme():Void {}

	override function initialize():Void {
		super.initialize();

		this.selectedTextFormat = this.textFormat;
		this.setTextFormatForState(ToggleButtonState.DOWN(false), this.textFormat);

		this.iconPosition = MANUAL;
		this.gap = CanTheme.DEFAULT_PADDING;

		this.addEventListener(FeathersEvent.STATE_CHANGE, this.stateChangeHandler);
	}

	@:access(ir.grantech.canvas.themes.CanTheme)
	override private function update():Void {
		if (this.isInvalid(InvalidationFlag.DATA)) {
			var theme = Std.downcast(Theme.getTheme(), CanTheme);
			var skin:BaseGraphicsPathSkin = null;
			if (isDivider) {
				skin = new DividerSkin(CanTheme.DPI * 4);
				skin.border = LineStyle.SolidColor(CanTheme.DPI * 0.5, theme.dividerColor);
			} else {
				skin = new RectangleSkin();
				skin.selectedFill = SolidColor(theme.dividerColor);
				skin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(theme.dividerColor, 0.2));
			}
			skin.fill = theme.getContainerFill();
			this.backgroundSkin = skin;

			if (!isDivider) {
				if (this.shortKey == null) {
					this.icon = new ScaledBitmap("chevron-r");
				} else {
					if (this.hintField == null) {
						this.hintField = new TextField();
						this.hintField.embedFonts = true;
						this.hintField.defaultTextFormat = this.textFormat;
						this.hintField.autoSize = TextFieldAutoSize.RIGHT;
						this.hintField.selectable = false;
						this.addChild(this.hintField);
					}
					this.hintField.text = shortKey;
				}
			}
		}
		super.update();
	}

	private function stateChangeHandler(event:Event):Void {
		if (!isDivider && Type.enumEq(currentState, ToggleButtonState.HOVER(false)))
			CanEvent.dispatch(this, CanEvent.ITEM_HOVER, this.shortKey == null, true);
	}

	override private function layoutContent():Void {
		if (isDivider)
			return;

		this.refreshTextFieldDimensions(false);

		this.textField.x = this.paddingLeft;
		this.textField.y = (this.actualHeight - this.textField.height) * 0.5;

		if (this.shortKey == null) {
			this.icon.x = this.actualWidth - this.paddingRight - this.icon.width;
			this.icon.y = (this.actualHeight - this.icon.height) * 0.5;
		} else {
			this.hintField.x = this.actualWidth - this.paddingRight - this.hintField.width;
			this.hintField.y = (this.actualHeight - this.hintField.height) * 0.5;
		}
	}
}
