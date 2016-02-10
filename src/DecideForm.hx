package ;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.events.Event;
import Story;

class DecideForm extends Sprite
{
	public var prompt:TextField;
	public var buttons:Array<Button>;
	public var execCallback:Dynamic;

	private var params:Array<String>;

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		visible = false;
		buttons = [];
		var topPadding:Int = 30;
		var sidePadding:Int = 30;
		var innerPadding:Int = 20;

		graphics.beginFill(0x000000, 0.25);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);

		prompt = new TextField();
		prompt.defaultTextFormat = new TextFormat(null, 20);
		prompt.autoSize = TextFieldAutoSize.CENTER;
		prompt.width = stage.stageWidth;
		prompt.y = 0;
		prompt.text = "Test";
		addChild(prompt);

		for (i in 0...5) {
			var b:Button = new Button(
					"img/buttonUp.png",
					"img/buttonOver.png",
					"img/buttonDown.png",
					"<test button text>");
			b.bitmap.width = stage.stageWidth - (sidePadding * 2);
			b.bitmap.height = 60;
			b.x = sidePadding;
			b.y = topPadding + (b.height + innerPadding) * i;
			b.onClick = decisionClicked.bind(i);
			addChild(b);
			buttons.push(b);
		}
	}

	public function show(
			promptString:String,
			labels:Array<String>,
			params:Array<String>):Void {

		visible = true;
		prompt.text = promptString;
		this.params = params;
		for (b in buttons) b.visible = false;
		for (i in 0...labels.length) {
			buttons[i].visible = true;
			buttons[i].textField.text = labels[i];
		}
	}

	public function update():Void {
		for (b in buttons) b.update();
	}

	private function decisionClicked(buttonIndex:Int):Void {
		var commandStrings:Array<String> = params[buttonIndex].split(" ");
		var newC:Command = {};
		newC.type = commandStrings[0];
		newC.params = [commandStrings[1]];
		newC.len = 0;

		execCallback(newC);
		visible = false;
	}
}
