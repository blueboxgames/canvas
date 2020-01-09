package ir.grantech.canvas.controls.groups;

import feathers.controls.LayoutGroup;
import openfl.display.Shape;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

class CanZoom extends LayoutGroup {
	private var scene:CanScene;

	public var scale(default, set):Float = 1;

	private function set_scale(value:Float):Float {
		if (0.1 > value)
			value = 0.1;
		if (10 < value)
			value = 10;
		if (this.scale == value)
			return this.scale;

		this.scale = value;
		this.scene.scaleX = this.scene.scaleY = value;

		return this.scale;
	}

	override function initialize() {
		super.initialize();

		this.scene = new CanScene();
		this.addChild(this.scene);

		var mask = new Shape();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(0, 0, 100, 100);
		this.scene.mask = mask;
		this.backgroundSkin = mask;

		this.stage.addEventListener(KeyboardEvent.KEY_UP, this.stage_keyUpHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.stage_keyDownHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.stage_mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.stage_mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.stage_mouseWeelHandler);
	}

	private function stage_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode != 32) // is not space bar
			return;
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.stage_keyDownHandler);
		var dragMode = mouseX > 0 && mouseX < this._layoutMeasurements.width;
		Mouse.cursor = dragMode ? MouseCursor.HAND : MouseCursor.AUTO;
	}

	private function stage_keyUpHandler(event:KeyboardEvent):Void {
		if (event.keyCode == 0x30) {
			if (event.ctrlKey)
				this.scene.scaleX = this.scene.scaleY = 1;
			return;
		}
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.stage_keyDownHandler);
		this.drop();
	}

	private function stage_mouseDownHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.stage_mouseDownHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.stage_mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.stage_mouseUpHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, this.stage_mouseUpHandler);
		if (event.type == MouseEvent.MOUSE_DOWN && Mouse.cursor != MouseCursor.HAND)
			return;
		this.drag();
	}

	private function stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.stage_mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.stage_mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.stage_mouseDownHandler);
		this.drop();
	}

	private function stage_mouseWeelHandler(event:MouseEvent):Void {
		var zoomMode = event.altKey || event.ctrlKey;
		#if mac
		zoomMode = zoomMode || event.commandKey;
		#end

		if (zoomMode)
			this.scale += event.delta * this.scene.scaleX * 0.1;
		else if (event.shiftKey)
			this.scene.x += event.delta * 10;
		else
			this.scene.y += event.delta * 10;
	}

	private function drag():Void {
		Mouse.cursor = MouseCursor.HAND;
		this.scene.startDrag();
	}

	private function drop():Void {
		this.scene.stopDrag();
		Mouse.cursor = MouseCursor.AUTO;
	}
}
