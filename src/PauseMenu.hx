package ;

import openfl.display.*;
import Story;

class PauseMenu extends Sprite
{
	public var execCallback:Dynamic;

	private var _bg:Sprite;
	private var _buttons:Array<Button>;

	public function new() {
		super();

		visible = mouseEnabled = mouseChildren = false;
		_bg = new Sprite();
		_bg.graphics.beginFill(0, 0.8);
		_bg.graphics.drawRect(0, 0, 400, 600);
		addChild(_bg);

		_buttons = [];
		var labels:Array<String> = [ 
			"Save in slot 1",
			"Save in slot 2",
			"Save in slot 3",
			"Load from slot 1",
			"Load from slot 2",
			"Load from slot 3",
			"Quit" ];

		for (l in labels) {
			var b:Button = new Button(
					"img/buttonUp.png",
					"img/buttonOver.png",
					"img/buttonDown.png",
					l);

			b.bitmap.width = 200;
			b.bitmap.height = 50;
			b.x = width / 2 - b.width / 2;
			b.y = (20 + b.height) * (labels.indexOf(l) + 1);
			b.onClick = buttonClicked.bind(l);
			addChild(b);

			_buttons.push(b);
		}
	}

	public function show():Void {
		visible = true;
	}

	public function hide():Void {
		visible = false;
	}
	
	public function update():Void {
		for (b in _buttons) b.update();
	}

	private function buttonClicked(l:String):Void {
		var proc:String = "";

		if (l.substr(0, 12) == "Save in slot") proc = "save";
		if (l.substr(0, 14) == "Load from slot") proc = "load";

		if (proc == "save" || proc == "load") {
			var slot:Int = Std.parseInt(l.charAt(l.length - 1));
			var c:Command = {};
			c.code = '$proc($slot);';
			execCallback(c);
		}

	}

}
