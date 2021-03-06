package ir.grantech.canvas.controls;

import ir.grantech.canvas.controls.groups.CanScene;
import ir.grantech.canvas.drawables.CanItems;
import ir.grantech.canvas.services.Commands;
import ir.grantech.canvas.services.Inputs;
import ir.grantech.canvas.themes.CanTheme;
import ir.grantech.canvas.utils.Cursor;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class TransformHint extends Sprite {
	static final MODE_NONE:Int = -1;
	static final MODE_REGISTER:Int = 0;
	static final MODE_TRANSLATE:Int = 1;
	static final MODE_SCALE:Int = 2;
	static final MODE_ROTATE:Int = 3;

	static final SNAP:Int = 16;

	public function setVisible(visible:Bool, all:Bool):Void {
		if (this.lines[0].visible == visible)
			return;
		for (i in 0...8) {
			this.lines[i].visible = visible;
			this.scaleAnchores[i].visible = visible;
			this.rotateAnchores[i].visible = visible;
		}
		if (all)
			this.register.visible = visible;
		this.register.alpha = visible ? 1 : 0.5;
	}

	private var mode:Int = -1;
	private var radius:Float;
	private var lineThickness:Float;

	private var main:Shape;
	private var hitAnchor:Int;
	private var register:Shape;
	private var lines:Array<Shape>;
	private var owner:DisplayObjectContainer;
	private var scaleAnchores:Array<ScaleAnchor>;
	private var rotateAnchores:Array<RotateAnchor>;
	private var mouseTranslateBegin:Point;
	private var mouseScaleBegin:Point;
	private var mouseAngleBegin:Float;
	private var scaleBegin:Point;
	private var angleBegin:Float;
	private var resizeBegin:Rectangle;
	private var resizeUpdate:Rectangle;
	private var horizontalHint:Shape;
	private var verticalHint:Shape;
	private var horizontalHintPoints:Array<Float>;
	private var verticalHintPoints:Array<Float>;
	private var snapMode:Int = -1;

	public var targets:CanItems;

	public function new(owner:DisplayObjectContainer) {
		super();

		this.owner = owner;

		this.radius = 2 * CanTheme.DPI;
		this.lineThickness = 0.5 * CanTheme.DPI;

		this.main = new Shape();
		this.main.graphics.beginFill(0, 0);
		this.main.graphics.drawRect(0, 0, 100, 100);
		this.addChild(this.main);

		this.doubleClickEnabled = true;
		this.mouseTranslateBegin = new Point();
		this.mouseScaleBegin = new Point();
		this.scaleBegin = new Point();
		this.resizeBegin = new Rectangle();
		this.resizeUpdate = new Rectangle();
		this.horizontalHintPoints = [0, CanScene.WIDTH * 0.5, CanScene.WIDTH];
		this.verticalHintPoints = [0, CanScene.HEIGHT * 0.5, CanScene.HEIGHT];

		this.register = this.addCircle(0, 0, this.radius + 1, 0x004488);
		this.register.blendMode = BlendMode.INVERT;
		this.lines = new Array<Shape>();
		this.scaleAnchores = new Array<ScaleAnchor>();
		this.rotateAnchores = new Array<RotateAnchor>();
		for (i in 0...8) {
			var sa = new ScaleAnchor(this.radius, this.lineThickness, CanTheme.HINT_COLOR);
			this.addChild(sa);
			this.scaleAnchores.push(sa);

			var ra = new RotateAnchor(this.radius, this.lineThickness, CanTheme.HINT_COLOR);
			this.addChild(ra);
			this.rotateAnchores.push(ra);

			this.lines.push(this.addLine(i == 2 || i == 3 || i == 6 || i == 7, 100));
		}
		this.lines[0].x = this.radius;
		this.lines[5].x = this.radius;
		this.lines[2].y = this.radius;
		this.lines[7].y = this.radius;

		this.horizontalHint = new Shape();
		this.horizontalHint.visible = false;
		this.horizontalHint.graphics.lineStyle(CanTheme.DPI * 0.5, CanTheme.HINT_COLOR);
		this.horizontalHint.graphics.moveTo(0, 0);
		this.horizontalHint.graphics.lineTo(0, CanScene.HEIGHT);
		this.owner.addChild(this.horizontalHint);
		
		this.verticalHint = new Shape();
		this.verticalHint.visible = false;
		this.verticalHint.graphics.lineStyle(CanTheme.DPI * 0.5, CanTheme.HINT_COLOR);
		this.verticalHint.graphics.moveTo(0, 0);
		this.verticalHint.graphics.lineTo(CanScene.WIDTH, 0);
		this.owner.addChild(this.verticalHint);

		this.addEventListener(MouseEvent.DOUBLE_CLICK, this.doubleClickHandler);
	}

	private function stage_mouseMoveHandler(event:MouseEvent):Void {
		if (this.mode == MODE_NONE) {
			var anchor = this.getAnchor();
			if (anchor < 0 || anchor == 8 || anchor == 9) {
				Cursor.instance.mode = Cursor.MODE_NONE;
				return;
			}
			Cursor.instance.mode = anchor > 9 ? Cursor.MODE_ROTATE : Cursor.MODE_SCALE;
		}

		if (Cursor.instance.mode != MODE_NONE) {
			Cursor.instance.rotation = this.rotation + Math.atan2(this.mouseY - this.register.y, this.mouseX - this.register.x) * 180 / Math.PI;
			Cursor.instance.x = event.stageX;
			Cursor.instance.y = event.stageY;
			event.updateAfterEvent();
		}
	}

	private function doubleClickHandler(event:MouseEvent):Void {
		if (!this.register.hitTestPoint(stage.mouseX, stage.mouseY, true))
			return;
		event.stopImmediatePropagation();
		this.targets.pivot.setTo(0.5, 0.5);
		if (this.targets.length == 1)
			this.targets.get(0).layer.pivot.setTo(0.5, 0.5);
		this.resetRegister();
	}

	private function addCircle(fillColor:UInt, fillAlpha:Float, radius:Float, lineColor:UInt):Shape {
		var c:Shape = new Shape();
		c.graphics.beginFill(fillColor, fillAlpha);
		c.graphics.lineStyle(lineThickness, lineColor);
		c.graphics.drawCircle(0, 0, radius);
		this.addChild(c);
		return c;
	}

	private function addLine(vertical:Bool, length:Float):Shape {
		var l:Shape = new Shape();
		this.drawLine(l, vertical, length, CanTheme.HINT_COLOR);
		this.addChild(l);
		return l;
	}

	private function drawLine(l:Shape, vertical:Bool, length:Float, lineColor:UInt):Void {
		l.graphics.clear();
		l.graphics.lineStyle(lineThickness, lineColor);
		l.graphics.moveTo(0, 0);
		l.graphics.lineTo(vertical ? 0 : length, vertical ? length : 0);
	}

	public function set(targets:CanItems):Void {
		this.targets = targets;

		if (targets.isFill) {
			this.owner.addChild(this);
			this.owner.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.stage_mouseMoveHandler);
		} else if (this.owner == parent) {
			this.owner.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.stage_mouseMoveHandler);
			this.owner.removeChild(this);
		}

		this.updateBounds();
	}


	public function updateBounds():Void {
		this.mode = MODE_NONE;
		Cursor.instance.mode = Cursor.MODE_NONE;
		if (this.targets == null || this.targets.isEmpty)
			return;
		this.setVisible(true, true);
		this.register.visible = !this.targets.isUI;

		var w = 0.0;
		var h = 0.0;
		this.rotation = 0;
		this.x = this.targets.bounds.x;
		this.y = this.targets.bounds.y;
		w = this.targets.bounds.width;
		h = this.targets.bounds.height;

		this.main.width = w;
		this.main.height = h;

		this.scaleAnchores[1].x = this.rotateAnchores[1].x = w * 0.5;
		this.scaleAnchores[2].x = this.rotateAnchores[2].x = w;
		this.scaleAnchores[3].x = this.rotateAnchores[3].x = w;
		this.scaleAnchores[3].y = this.rotateAnchores[3].y = h * 0.5;
		this.scaleAnchores[4].x = this.rotateAnchores[4].x = w;
		this.scaleAnchores[4].y = this.rotateAnchores[4].y = h;
		this.scaleAnchores[5].x = this.rotateAnchores[5].x = w * 0.5;
		this.scaleAnchores[5].y = this.rotateAnchores[5].y = h;
		this.scaleAnchores[6].x = this.rotateAnchores[6].x = 0;
		this.scaleAnchores[6].y = this.rotateAnchores[6].y = h;
		this.scaleAnchores[7].x = this.rotateAnchores[7].x = 0;
		this.scaleAnchores[7].y = this.rotateAnchores[7].y = h * 0.5;

		for (i in 0...8)
			this.drawLine(this.lines[i], i == 2 || i == 3 || i == 6 || i == 7, (i == 2 || i == 3 || i == 6 || i == 7 ? h : w) * 0.5 - this.radius * 2,
				CanTheme.HINT_COLOR);

		this.lines[1].x = w * 0.5 + this.radius;
		this.lines[2].x = w;
		this.lines[3].x = w;
		this.lines[3].y = h * 0.5 + this.radius;
		this.lines[4].x = w * 0.5 + this.radius;
		this.lines[4].y = h;
		this.lines[5].y = h;
		this.lines[6].y = h * 0.5 + this.radius;

		this.resetRegister();

		// insert hint points
		this.horizontalHint.visible = false;
		this.verticalHint.visible = false;

		var i = 3;
		for (l in Commands.instance.layers) {
			if (this.targets.indexOf(l.item) > -1)
				continue;

			var b:Rectangle = l.item.getBounds(l.item.parent);
			this.horizontalHintPoints[i] = b.left;
			this.horizontalHintPoints[i + 1] = b.right;
			this.verticalHintPoints[i] = b.top;
			this.verticalHintPoints[i + 1] = b.bottom;
			i += 2;
		}
		while (this.horizontalHintPoints.length > i) {
			this.horizontalHintPoints.pop();
			this.verticalHintPoints.pop();
		}
	}

	private function getAnchor():Int {
		if (this.register.hitTestPoint(stage.mouseX, stage.mouseY, true))
			return 8;
		for (i in 0...8)
			if (this.scaleAnchores[i].hitTestPoint(stage.mouseX, stage.mouseY, true))
				return i;
		if (this.main.hitTestPoint(stage.mouseX, stage.mouseY, true))
			return 9;
		for (i in 0...8)
			if (this.rotateAnchores[i].hitTestPoint(stage.mouseX, stage.mouseY, true))
				return 10 + i;
		return -1;
	}

	public function perform(state:Int):Void {
		if (this.targets == null || this.targets.isEmpty)
			return;
		if (state == Inputs.PHASE_BEGAN) {
			// set register point
			var r:Rectangle = this.register.getBounds(parent);
			this.targets.pivotV.setTo(r.left + r.width * 0.5, r.top + r.height * 0.5);

			// detect anchores
			this.hitAnchor = this.getAnchor();
			if (this.hitAnchor < 0)
				return;
			if (this.hitAnchor < 8) {
				this.mode = MODE_SCALE;
			} else if (this.hitAnchor == 8) {
				this.mode = MODE_REGISTER;
			} else if (this.hitAnchor == 9) {
				this.mode = MODE_TRANSLATE;
			} else if (this.hitAnchor > 9) {
				this.mode = MODE_ROTATE;
				this.hitAnchor -= 10;
			}
			this.setVisible(false, this.mode == MODE_TRANSLATE);
		}

		// porform methods
		if (this.hitAnchor < 0)
			return;
		if (this.mode == MODE_REGISTER)
			this.performRegister(state);
		else if (this.mode == MODE_TRANSLATE)
			this.performTranslate(state);
		else if (this.mode == MODE_ROTATE)
			this.performRotate(state);
		else if (this.mode == MODE_SCALE)
			if (this.targets.isUI)
				this.performResize(state);
			else
				this.performScale(state);
	}

	private function performRegister(state:Int):Void {
		this.targets.pivot.setTo(this.mouseX / this.scaleAnchores[4].x, this.mouseY / this.scaleAnchores[4].y);
		this.snapTo(this.targets.pivot, -0.05, 0.05, -0.05, 0.05);
		this.snapTo(this.targets.pivot, 0.45, 0.55, -0.05, 0.05);
		this.snapTo(this.targets.pivot, 0.95, 1.05, -0.05, 0.05);
		this.snapTo(this.targets.pivot, -0.05, 0.05, 0.45, 0.55);
		this.snapTo(this.targets.pivot, 0.45, 0.55, 0.45, 0.55);
		this.snapTo(this.targets.pivot, 0.95, 1.05, 0.45, 0.55);
		this.snapTo(this.targets.pivot, -0.05, 0.05, 0.95, 1.05);
		this.snapTo(this.targets.pivot, 0.45, 0.55, 0.95, 1.05);
		this.snapTo(this.targets.pivot, 0.95, 1.05, 0.95, 1.05);
		if (this.targets.length == 1)
			this.targets.get(0).layer.pivot.setTo(this.targets.pivot.x, this.targets.pivot.y);
		this.resetRegister();
	}

	private function snapTo(c:Point, x1:Float, x2:Float, y1:Float, y2:Float):Void {
		if (c.x > x1 && c.x < x2 && c.y > y1 && c.y < y2)
			c.setTo(x1 + (x2 - x1) * 0.5, y1 + (y2 - y1) * 0.5);
	}

	private function resetRegister():Void {
		this.register.x = this.scaleAnchores[4].x * this.targets.pivot.x;
		this.register.y = this.scaleAnchores[4].y * this.targets.pivot.y;
	}

	private function performRotate(state:Int):Void {
		var rad = Math.atan2(this.mouseY - this.register.y, this.mouseX - this.register.x);
		if (state == Inputs.PHASE_BEGAN) {
			this.angleBegin = Math.atan2(this.targets.get(0).transform.matrix.b, this.targets.get(0).transform.matrix.a);
			this.mouseAngleBegin = rad;
			return;
		}

		// calculate destination angle
		var angle = this.angleBegin + rad - this.mouseAngleBegin;
		if (Inputs.instance.shiftKey || Inputs.instance.ctrlKey) {
			var step = Math.PI * (Inputs.instance.shiftKey ? 0.5 : 0.25);
			var mod = angle % step;
			angle += (mod > step * 0.5 ? step - mod : -mod); // snap to 90 or 45
		}
		Commands.instance.commit(Commands.ROTATE, [this.targets, angle]);
	}

	private function performScale(state:Int):Void {
		if (state == Inputs.PHASE_BEGAN) {
			this.mouseScaleBegin.setTo(this.mouseX - this.register.x, this.mouseY - this.register.y);
			this.scaleBegin.setTo(this.targets.bounds.width, this.targets.bounds.height);
			return;
		}

		// calculate delta scale
		var sx = this.scaleBegin.x * (this.mouseX - this.register.x) / this.mouseScaleBegin.x;
		var sy = this.scaleBegin.y * (this.mouseY - this.register.y) / this.mouseScaleBegin.y;

		if (Inputs.instance.shiftKey) {
			sy = sx;
		} else {
			if (this.hitAnchor == 1 || this.hitAnchor == 5)
				sx = this.scaleBegin.x;
			else if (this.hitAnchor == 3 || this.hitAnchor == 7)
				sy = this.scaleBegin.y;
		}
		Commands.instance.commit(Commands.SCALE, [this.targets, sx, sy]);
	}

	private function performResize(state:Int):Void {
		if (state == Inputs.PHASE_BEGAN) {
			this.mouseScaleBegin.setTo(this.mouseX, this.mouseY);
			this.resizeBegin.setTo(this.targets.bounds.x, this.targets.bounds.y, this.targets.bounds.width, this.targets.bounds.height);
			return;
		}

		// calculate delta scale
		var sx = this.mouseX - this.mouseScaleBegin.x;
		var sy = this.mouseY - this.mouseScaleBegin.y;

		if (Inputs.instance.shiftKey) {
			sy = sx;
		} else {
			if (this.hitAnchor == 1 || this.hitAnchor == 5)
				sx = 0;
			else if (this.hitAnchor == 3 || this.hitAnchor == 7)
				sy = 0;
		}

		// create rect-scale
		resizeUpdate.setTo(this.resizeBegin.x, this.resizeBegin.y, this.resizeBegin.width + sx, this.resizeBegin.height + sy);
		if (this.hitAnchor == 0 || this.hitAnchor == 6 || this.hitAnchor == 7) {
			resizeUpdate.x = this.resizeBegin.x + sx;
			resizeUpdate.width = this.resizeBegin.width - sx;
		}
		if (this.hitAnchor == 0 || this.hitAnchor == 1 || this.hitAnchor == 2) {
			resizeUpdate.y = this.resizeBegin.y + sy;
			resizeUpdate.height = this.resizeBegin.height - sy;
		}

		Commands.instance.commit(Commands.RESIZE, [this.targets, resizeUpdate]);
	}

	private function performTranslate(state:Int):Void {
		if (state == Inputs.PHASE_BEGAN) {
			this.mouseTranslateBegin.setTo(stage.mouseX / Inputs.instance.zoom, stage.mouseY / Inputs.instance.zoom);
			return;
		}

		// calculate delta translate
		var tx = stage.mouseX / Inputs.instance.zoom - this.mouseTranslateBegin.x;
		var ty = stage.mouseY / Inputs.instance.zoom - this.mouseTranslateBegin.y;

		// snapping
		tx = this.getSnapH(tx);
		this.horizontalHint.visible = this.snapMode > -1;
		if (this.snapMode > -1)
			horizontalHint.x = snapMode == 0 ? targets.bounds.left : (snapMode == 1 ? targets.bounds.center : targets.bounds.right);

		ty = this.getSnapV(ty);
		this.verticalHint.visible = this.snapMode > -1;
		if (this.snapMode > -1)
			verticalHint.y = snapMode == 0 ? targets.bounds.top : (snapMode == 1 ? targets.bounds.middle : targets.bounds.bottom);

		this.mouseTranslateBegin.setTo(tx + this.mouseTranslateBegin.x, ty + this.mouseTranslateBegin.y);
		Commands.instance.commit(Commands.TRANSLATE, [this.targets, tx, ty]);
	}

	private function getSnapH(value:Float):Float {
		for (h in this.horizontalHintPoints) {
			this.snapMode = 0;
			if (this.targets.bounds.left + value - SNAP < h && this.targets.bounds.left + value + SNAP > h)
				return h - this.targets.bounds.left;
			this.snapMode = 1;
			if (this.targets.bounds.center + value - SNAP < h && this.targets.bounds.center + value + SNAP > h)
				return h - this.targets.bounds.center;
			this.snapMode = 2;
			if (this.targets.bounds.right + value - SNAP < h && this.targets.bounds.right + value + SNAP > h)
				return h - this.targets.bounds.right;
		}
		this.snapMode = -1;
		return value;
	}

	private function getSnapV(value:Float):Float {
		for (v in this.verticalHintPoints) {
			this.snapMode = 0;
			if (this.targets.bounds.top + value - SNAP < v && this.targets.bounds.top + value + SNAP > v)
				return v - this.targets.bounds.top;
			this.snapMode = 1;
			if (this.targets.bounds.middle + value - SNAP < v && this.targets.bounds.middle + value + SNAP > v)
				return v - this.targets.bounds.middle;
			this.snapMode = 2;
			if (this.targets.bounds.bottom + value - SNAP < v && this.targets.bounds.bottom + value + SNAP > v)
				return v - this.targets.bounds.bottom;
		}
		this.snapMode = -1;
		return value;
	}
}

class ScaleAnchor extends Sprite {
	public function new(radius:Float, thinkness:Float, lineColor:UInt) {
		super();
		this.graphics.lineStyle(thinkness, lineColor);
		this.graphics.beginFill(0, 0);
		this.graphics.drawCircle(0, 0, radius);
	}
}

class RotateAnchor extends Shape {
	public function new(radius:Float, thinkness:Float, lineColor:UInt) {
		super();
		this.graphics.beginFill(0xFF, 0);
		this.graphics.drawCircle(0, 0, radius * 4);
	}
}
