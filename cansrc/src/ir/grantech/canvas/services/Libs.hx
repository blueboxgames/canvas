package ir.grantech.canvas.services;

import openfl.display.Stage;
import openfl.display.BitmapData;

class Libs extends BaseService {
	private var map:Map<Int, BitmapData>;
	private var stage:Stage;

	/**
		The singleton method of Libs.
		```hx
		Libs.instance. ....
		```
		@since 1.0.0
	**/
	static public var instance(get, null):Libs;

	static private function get_instance():Libs {
		return BaseService.get(Libs);
	}

	public function new(stage:Stage) {
		super();
		this.stage = stage;
		this.stage.window.onDropFile.add(this.stage_onDropFileHandler);
	}

	private function stage_onDropFileHandler(path:String):Void {
		trace(path);
	}
}