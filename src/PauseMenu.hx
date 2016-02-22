package ;

import openfl.display.*;

class PauseMenu extends Sprite
{
	private var _bg:Sprite;

	public function new() {
		super();

		visible = mouseEnabled = mouseChildren = false;
		_bg = new Sprite();
		_bg.graphics.lineStyle(1);
		_bg.graphics.drawRect(0, 0, 400, 600);
		addChild(_bg);
	}

	public function show():Void {
		visible = mouseEnabled = mouseChildren = true;
	}

	public function hide():Void {
		visible = mouseEnabled = mouseChildren = false;
	}

}
