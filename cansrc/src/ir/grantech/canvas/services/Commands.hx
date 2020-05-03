package ir.grantech.canvas.services;

import ir.grantech.canvas.drawables.CanItems;
import ir.grantech.canvas.events.CanEvent;
import ir.grantech.canvas.services.Layers.Layer;

class Commands extends BaseService {
	// layer commands
	static public final ADDED:String = "added";
	static public final REMOVED:String = "removed";
	static public final SELECT:String = "select";
	static public final ENABLE:String = "enable";
	static public final ORDER:String = "order";
	
	// transform commands
	static public final TRANSLATE:String = "translate";
	static public final SCALE:String = "scale";
	static public final ROTATE:String = "rotate";
	static public final RESIZE:String = "resize";
	static public final RESET:String = "reset";
	static public final ALIGN:String = "align";
	
	// base commands
	static public final ALPHA:String = "alpha";
	static public final VISIBLE:String = "visible";
	static public final BLEND_MODE:String = "blendMode";
	
	// drawing commands
	static public final FILL_ENABLED:String = "fillEnabled";
	static public final FILL_COLOR:String = "fillColor";
	static public final FILL_ALPHA:String = "fillAlpha";
	static public final BORDER_ENABLED:String = "borderEnabled";
	static public final BORDER_COLOR:String = "borderColor";
	static public final BORDER_ALPHA:String = "borderAlpha";
	static public final BORDER_SIZE:String = "borderSize";
	static public final CORNER_RADIUS:String = "cornerRadius";

	// text commands
	static public final TEXT_FONT:String = "textFont";
	static public final TEXT_SIZE:String = "textSIze";
	static public final TEXT_COLOR:String = "textColor";
	static public final TEXT_ALIGN:String = "textAlign";
	static public final TEXT_LETTERPACE:String = "textLetterspace";
	static public final TEXT_LINESPACE:String = "textLineSpace";
	static public final TEXT_AUTOSIZE:String = "txtAutosize";

	/**
		The singleton method of Commands.
		```hx
		Commands.instance. ....
		```
		@since 1.0.0
	**/
	static public var instance(get, null):Commands;

	static private function get_instance():Commands {
		return BaseService.get(Commands);
	}

	private var layers:Layers;

	public function new() {
		super();
		this.layers = new Layers();
	}

	public function commit(command:String, args:Array<Dynamic> = null):Void {
		switch (command) {
			case ADDED:
				var layer = new Layer(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
				this.layers.add(layer);
				args = [layer.item];
			case REMOVED:
				var items = cast(args[0], CanItems).items;
				for (i in items)
					this.layers.remove(i.layer);
			case ORDER:
				this.layers.changeOrder(args[0], args[1]);
				args[2] = this.layers;
		}
		CanEvent.dispatch(this, command, args);
	}
}
