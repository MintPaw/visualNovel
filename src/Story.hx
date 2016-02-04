package ;

import openfl.display.Sprite;
import openfl.display.SimpleButton;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.Assets;

class Story extends Sprite
{
	var textField:TextField;

	var commands:Array<Command>;

	var storyText:String;
	var currentChar:Int;
	var nextWordTime:Int;
	var lastTime:Int;
	var paused:Bool;
	var deciding:Bool;
	var clearNext:Bool;

	var decideForm:DecideForm;

	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // Get story
			storyText = Assets.getText("assets/story/main.txt");
			commands = [{ type: "label", params: ["main"], pos: -1, len: 1 }];

			var reg:EReg = new EReg("\\(.*\\)", "ig");
			reg.map(
					storyText, function(r) {
						var commandString:String = reg.matched(0);
						commandString = commandString.substring(1, commandString.length - 1);
						if (commandString.charAt(1) == "(") return commandString;
						if (commandString.charAt(1) == "/" && commandString.charAt(2) == "/")
							return commandString;

						var commandSubStrings:Array<String> = commandString.split(" ");
						var c:Command = {};
						c.type = commandSubStrings.shift();
						c.params = [commandSubStrings.join(" ")];
						c.pos = reg.matchedPos().pos;
						c.len = reg.matchedPos().len;
						commands.push(c);

						if (c.type == "decision")
						{
							var pCopy:String = c.params[0];
							for (i in 0...99) {
								var startCut:Int = pCopy.indexOf("(")+1;
								var endCut:Int = pCopy.indexOf(")")-1;
								c.params[i] = pCopy.substr(startCut, endCut);
								pCopy = pCopy.substr(pCopy.indexOf("(", endCut), pCopy.length);
								if (pCopy.length <= 2) break;
							}
						}

						return commandString;
					});
		}

		{ // Setup UI
			var botPadding:Int = 30;
			var sidePadding:Int = 30;
			var innerPadding:Int = 20;

			decideForm = {};
			decideForm.sprite = new Sprite();
			decideForm.buttons = [];
			decideForm.texts = [];

			for (i in 0...5)
			{
				var b:SimpleButton = new SimpleButton( 
						new Bitmap(Assets.getBitmapData("assets/img/buttonUp.png")),
						new Bitmap(Assets.getBitmapData("assets/img/buttonOver.png")),
						new Bitmap(Assets.getBitmapData("assets/img/buttonDown.png")),
						new Bitmap(Assets.getBitmapData("assets/img/buttonDown.png")));
				b.width = stage.stageWidth - (sidePadding * 2);
				b.height = 70;
				b.x = sidePadding;
				b.y = 100 + (b.height + innerPadding) * i;

				var t:TextField = new TextField();
				t.defaultTextFormat = new TextFormat(null, 20);
				t.border = true;
				t.text = "This is a test";
				t.autoSize = TextFieldAutoSize.CENTER;
				t.x = b.x + (b.width - t.width) / 2;
				t.y = b.y + (b.height - t.height) / 2;

				decideForm.sprite.addChild(b);
				decideForm.sprite.addChild(t);

				decideForm.buttons.push(b);
				decideForm.texts.push(t);
			}

			addChild(decideForm.sprite);

			textField = new TextField();
			textField.width = stage.stageWidth - (sidePadding * 2);
			textField.height = stage.stageHeight * 0.25;
			textField.x = sidePadding;
			textField.y = stage.stageHeight - textField.height - botPadding;
			textField.text = "";
			textField.border = true;
			textField.wordWrap = true;
			addChild(textField);
		}

		currentChar = 0;
		lastTime = getTime();
		stage.frameRate = 60;
		paused = false;
		deciding = false;
		clearNext = false;
		addChild(new openfl.display.FPS());

		addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		stage.focus = stage;
	}

	function update(e:Event):Void {
		var elapsed:Int = getTime() - lastTime;
		lastTime = getTime();

		if (!paused && !deciding) {
			if (nextWordTime <= 0) {
				nextWordTime = 16;
				updateStory();
			} else {
				nextWordTime -= elapsed;
			}
		}
	}

	function updateStory():Void {
		if (clearNext) {
			clearNext = false;
			textField.text = "";
		}

		for (c in commands) {
			if (c.pos == currentChar) {
				currentChar += c.len;
				exec(c);
			}
		}

		var char:String = storyText.charAt(currentChar);
		// trace(char, currentChar);

		if (textField.maxScrollV > 1) {
			paused = true;
			clearNext = true;
			for (i in 0...100) {
				if (storyText.charAt(currentChar - i) == " " ||
						storyText.charAt(currentChar - i) == "\n") {
					currentChar -= (i-1);
					return;
				}
			}
		}

		textField.appendText(char);
		currentChar++;
	}

	function exec(c:Command):Void
	{
		trace('Running $c at line $currentChar');

		if (c.type == "pause") {
			paused = true;
		} else if (c.type == "decision") {
			deciding = true;
		}
	}

	function keyUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.SPACE) paused = false;
	}

	function getTime():Int
	{
		return Std.int(haxe.Timer.stamp() * 1000);
	}
}

typedef Command = 
{
	?type:String,
	?params:Array<String>,
	?pos:Int,
	?len:Int
}

typedef DecideForm = 
{
	?sprite:Sprite,
	?buttons:Array<SimpleButton>,
	?texts:Array<TextField>
}
