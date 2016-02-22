package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.Assets;

class Button extends Sprite
{
	public var onClick:Void -> Void;
	public var textField:TextField;

	public var bitmap:Bitmap;
	public var up:BitmapData;
	public var over:BitmapData;
	public var down:BitmapData;

	public var state:Int;

	public function new(
			upPath:String,
			overPath:String,
			downPath:String,
			text:String = "") {
		super();

		state = 0;
		up = Assets.getBitmapData(upPath);
		over = Assets.getBitmapData(overPath);
		down = Assets.getBitmapData(downPath);

		bitmap = new Bitmap(new BitmapData(up.width, up.height));
		bitmap.bitmapData.draw(up);
		addChild(bitmap);

		textField = new TextField();
		textField.embedFonts = true;
		textField.defaultTextFormat = new TextFormat("Open Sans", 12);
		textField.text = text;
		textField.autoSize = TextFieldAutoSize.CENTER;
		textField.mouseEnabled = false;
		addChild(textField);
	}

	public function update() {
		if (stage == null) return;

		textField.x = (width - textField.width) / 2;
		textField.y = (height - textField.height) / 2;

		var mouseX:Int = Std.int(stage.mouseX);
		var mouseY:Int = Std.int(stage.mouseY);

		var bRect:Rectangle = getBounds(stage);

		if (bRect.contains(mouseX, mouseY)) {
			if (Story.mouseDown && state != 2) {
				bitmap.bitmapData.draw(down);
				state = 2;
			} else if (!Story.mouseDown && state != 1) {
				if (state == 2) onClick();
				bitmap.bitmapData.draw(over);
				state = 1;
			}

		} else if (state != 0) {
			bitmap.bitmapData.draw(up);
			state = 0;
		}
	}
}
