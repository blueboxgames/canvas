package ir.grantech.canvas.themes;

import feathers.graphics.FillStyle;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.BasicButton;
import feathers.skins.CircleSkin;
import feathers.controls.HSlider;
import feathers.controls.ButtonState;
import openfl.Assets;
import flash.display.Bitmap;
import openfl.display.Shape;
import feathers.controls.PopUpListView;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.CanTextInput;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.themes.steel.BaseSteelTheme;
import ir.grantech.canvas.controls.groups.panels.Panel;
import openfl.system.Capabilities;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class CanTheme extends BaseSteelTheme {
	// public static final VARIANT_INPUT_DISPLAY_LABEL = "canvas-theme-input-display-label";
	// public static final VARIANT_OPERATION_BUTTON = "canvas-theme-operation-button";
	static public var DPI:Int = 4;
	static public var DEFAULT_PADDING = 4;
	static public var CONTROL_SIZE = 32;

	public var headerTextColor:UInt;

	public function new() {
		super();
		DPI = Math.round(Capabilities.screenResolutionY / 500);
		DEFAULT_PADDING = DPI * 6;
		CONTROL_SIZE = DPI * 18;
		this.fontSize = Math.round(DPI * 5.5);
		this.headerFontSize = DPI * 5;
		this.textColor = this.darkMode ? 0x464646 : 0x464646;
		this.headerTextColor = this.disabledTextColor = this.darkMode ? 0xAaAaAa : 0xAaAaAa;
		// this is a dark theme, set set the default theme to dark mode
		// cast(Theme.fallbackTheme, IDarkModeTheme).darkMode = true;

		this.styleProvider.setStyleFunction(Application, null, setApplicationStyles);
		this.styleProvider.setStyleFunction(TextInput, null, setTextInputStyles);
		this.styleProvider.setStyleFunction(Panel, null, setPanelStyles);
		this.styleProvider.setStyleFunction(Label, null, setLabelStyles);
		this.styleProvider.setStyleFunction(Label, Label.VARIANT_DETAIL, setLabelDetailStyles);
		this.styleProvider.setStyleFunction(Label, Label.VARIANT_HEADING, setLabelHeadingStyles);
		this.styleProvider.setStyleFunction(Button, null, setButtonStyles);
		this.styleProvider.setStyleFunction(HSlider, null, setHSliderStyles);
		this.styleProvider.setStyleFunction(ItemRenderer, null, setItemRendererStyles);
		this.styleProvider.setStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON, setButtonPopupStyles);

		// this.styleProvider.setStyleFunction(Button, VARIANT_OPERATION_BUTTON, setOperationButtonStyles);
		// this.styleProvider.setStyleFunction(Label, VARIANT_INPUT_DISPLAY_LABEL, setInputDisplayLabelStyles);
	}

	// private var fontName = "_sans";
	// private var fontSize = 50;
	// private var textColor = 0xf1f1f1;
	private var activeColor = 0xff9500;
	private var controlColor = 0xfafafa;
	private var operationColor = 0xff9500;

	private function getInputDisplayLabelTextFormat():TextFormat {
		var result = this.getTextFormat();
		return result;
	}

	private function setApplicationStyles(app:Application):Void {
		if (app.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(app.stage.color);
			app.backgroundSkin = skin;
		}
	}

	public function setPanelStyles(bar:LayoutGroup):Void {
		if (bar.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.controlColor);
			bar.backgroundSkin = skin;
		}
	}

	private function setButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = SolidColor(this.controlColor, 0);
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null)
			button.textFormat = this.getTextFormat();

		button.paddingTop = DEFAULT_PADDING;
		button.paddingRight = DEFAULT_PADDING;
		button.paddingBottom = DEFAULT_PADDING;
		button.paddingLeft = DEFAULT_PADDING;
		button.gap = DEFAULT_PADDING;
	}

	private function setButtonPopupStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.cornerRadius = DPI * 4;
			skin.fill = SolidColor(this.controlColor, 1);
			skin.border = LineStyle.SolidColor(DPI * 0.5, this.disabledTextColor);
			skin.setBorderForState(ButtonState.DISABLED, LineStyle.SolidColor(DPI * 0.5, this.disabledTextColor, 0.5));
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null)
			button.textFormat = this.getTextFormat();

		if (button.getTextFormatForState(ButtonState.DISABLED) == null)
			button.setTextFormatForState(ButtonState.DISABLED, this.getDisabledTextFormat());

		button.paddingTop = DEFAULT_PADDING;
		button.paddingRight = DEFAULT_PADDING;
		button.paddingBottom = DEFAULT_PADDING;
		button.paddingLeft = DEFAULT_PADDING;
		button.gap = Math.POSITIVE_INFINITY;
		button.horizontalAlign = LEFT;
		button.minGap = 6.0;

		button.icon = new Bitmap(Assets.getBitmapData("chevron-d"));
		var bmp = new Bitmap(Assets.getBitmapData("chevron-d"));
		bmp.alpha = 0.5;
		button.setIconForState(ButtonState.DISABLED, bmp);
		button.iconPosition = RIGHT;
	}

	private function setTextInputStyles(input:TextInput):Void {
		if (input.backgroundSkin == null) {
			var inputSkin = new UnderlineSkin();
			// inputSkin.cornerRadius = 6.0;
			inputSkin.width = 160.0;
			inputSkin.fill = SolidColor(this.insetFillColor, 0);
			inputSkin.border = getInsetBorder();
			inputSkin.setBorderForState(TextInputState.FOCUSED, getThemeBorder());
			input.backgroundSkin = inputSkin;
		}

		if (input.textFormat == null)
			input.textFormat = getTextFormat();
		input.textFormat.size = this.headerFontSize;
		input.textFormat.align = TextFormatAlign.CENTER;
		if (Std.is(input, CanTextInput))
			input.textFormat.indent = cast(input, CanTextInput).icon != null ? DPI * 8 : 0;

		if (input.getTextFormatForState(TextInputState.DISABLED) == null) {
			var format = getDisabledTextFormat();
			format.size = this.headerFontSize;
			input.setTextFormatForState(TextInputState.DISABLED, format);
		}

		input.paddingTop = 6.0;
		input.paddingRight = 10.0;
		input.paddingBottom = 6.0;
		input.paddingLeft = 10.0;
	}

	private function setLabelStyles(label:Label):Void {
		if (label.textFormat == null)
			label.textFormat = this.getTextFormat();
		if (label.disabledTextFormat == null)
			label.disabledTextFormat = this.getDisabledTextFormat();
	}

	private function setLabelDetailStyles(label:Label):Void {
		if (label.textFormat == null)
			label.textFormat = this.getDetailTextFormat();
		if (label.disabledTextFormat == null)
			label.disabledTextFormat = this.getDisabledDetailTextFormat();
	}

	private function setLabelHeadingStyles(label:Label):Void {
		if (label.textFormat == null)
			label.textFormat = this.getHeaderTextFormat();
		if (label.disabledTextFormat == null)
			label.disabledTextFormat = this.getDisabledHeaderTextFormat();
	}

	private function setHSliderStyles(slider:HSlider):Void {
		if (slider.thumbSkin == null) {
			var thumbSkin = new CircleSkin();
			thumbSkin.border = LineStyle.SolidColor(DPI, this.textColor);
			thumbSkin.setBorderForState(ButtonState.DISABLED, LineStyle.SolidColor(DPI, this.textColor));
			thumbSkin.fill = SolidColor(this.controlColor, 1);
			thumbSkin.setFillForState(ButtonState.DOWN, SolidColor(this.textColor, 1));
			thumbSkin.width = DPI * 8;
			thumbSkin.height = DPI * 8;
			var thumb = new BasicButton();
			thumb.keepDownStateOnRollOut = true;
			thumb.backgroundSkin = thumbSkin;
			slider.thumbSkin = thumb;
		}

		if (slider.trackSkin == null) {
			var trackSkin = new RectangleSkin();
			trackSkin.fill = SolidColor(this.textColor, 1);
			trackSkin.setFillForState(ButtonState.DISABLED, SolidColor(this.disabledTextColor, 1));
			trackSkin.height = DPI;
			slider.trackSkin = trackSkin;
		}

		if (slider.secondaryTrackSkin == null) {
			var secondaryTrackSkin = new RectangleSkin();
			secondaryTrackSkin.fill = SolidColor(this.disabledTextColor, 0.5);
			secondaryTrackSkin.height = DPI;
			slider.secondaryTrackSkin = secondaryTrackSkin;
		}
	}

	private function setItemRendererStyles(itemRenderer:ItemRenderer):Void {
		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = this.getContainerFill();
			skin.border = this.getDividerBorder();
			skin.selectedFill = this.getActiveThemeFill();
			skin.setFillForState(ToggleButtonState.DOWN(false), this.getActiveThemeFill());
			skin.width = CONTROL_SIZE;
			skin.height = CONTROL_SIZE;
			skin.minWidth = CONTROL_SIZE;
			skin.minHeight = CONTROL_SIZE;
			itemRenderer.backgroundSkin = skin;
		}

		if (itemRenderer.textFormat == null)
			itemRenderer.textFormat = this.getTextFormat();

		if (itemRenderer.disabledTextFormat == null)
			itemRenderer.disabledTextFormat = this.getDisabledTextFormat();

		if (itemRenderer.selectedTextFormat == null)
			itemRenderer.selectedTextFormat = this.getActiveTextFormat();

		if (itemRenderer.getTextFormatForState(ToggleButtonState.DOWN(false)) == null)
			itemRenderer.setTextFormatForState(ToggleButtonState.DOWN(false), this.getActiveTextFormat());

		itemRenderer.paddingTop = DEFAULT_PADDING;
		itemRenderer.paddingRight = DEFAULT_PADDING;
		itemRenderer.paddingBottom = DEFAULT_PADDING;
		itemRenderer.paddingLeft = DEFAULT_PADDING;
		itemRenderer.horizontalAlign = LEFT;
	}

	override private function getHeaderTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.headerFontSize, this.headerTextColor);
	}

	override private function getActiveThemeFill():FillStyle {
		return SolidColor(this.textColor, 1);
	}
}
