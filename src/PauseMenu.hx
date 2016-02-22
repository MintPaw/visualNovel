package ;

import openfl.display.*;

class PauseMenu extends Sprite
{
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
		var labels:Array<String> = [ "Save", "Load", "Quit" ];
		for (l in labels) {
			var b:Button = new Button(
					"img/buttonUp.png",
					"img/buttonOver.png",
					"img/buttonDown.png",
					l);

			b.bitmap.width = 200;
			b.bitmap.height = 75;
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
		trace(l);

	}

}
