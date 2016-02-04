package ;

import openfl.display.Sprite;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
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
			var topPadding:Int = 30;
			var botPadding:Int = 30;
			var sidePadding:Int = 30;
			var innerPadding:Int = 20;

			decideForm = {};
			decideForm.sprite = new Sprite();
			decideForm.buttons = [];
			decideForm.texts = [];

			decideForm.prompt = new TextField();
			decideForm.prompt.defaultTextFormat = new TextFormat(null, 20);
			decideForm.prompt.autoSize = TextFieldAutoSize.CENTER;
			decideForm.prompt.width = stage.stageWidth;
			decideForm.prompt.y = 0;
			decideForm.prompt.text = "Test";
			decideForm.sprite.addChild(decideForm.prompt);

			var s = decideForm.sprite;
			s.graphics.beginFill(0x000000, 0.25);
			s.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);

			for (i in 0...5)
			{
				// new Bitmap(Assets.getBitmapData("assets/img/buttonUp.png")),
				// new Bitmap(Assets.getBitmapData("assets/img/buttonOver.png")),
				// new Bitmap(Assets.getBitmapData("assets/img/buttonDown.png")),
				// new Bitmap(Assets.getBitmapData("assets/img/buttonDown.png")));

				var b:Sprite = new Sprite();
				b.addChild(new Bitmap(Assets.getBitmapData("assets/img/buttonUp.png")));
				b.width = stage.stageWidth - (sidePadding * 2);
				b.height = 60;
				b.x = sidePadding;
				b.y = topPadding + (b.height + innerPadding) * i;
				b.addEventListener(MouseEvent.CLICK, decisionClicked);

				var t:TextField = new TextField();
				t.defaultTextFormat = new TextFormat(null, 20);
				t.border = true;
				t.text = "This is a test";
				t.autoSize = TextFieldAutoSize.CENTER;
				t.x = b.x + (b.width - t.width) / 2;
				t.y = b.y + (b.height - t.height) / 2;
				t.mouseEnabled = false;

				decideForm.sprite.addChild(b);
				decideForm.sprite.addChild(t);

				decideForm.buttons.push(b);
				decideForm.texts.push(t);
			}

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
		trace('Running $c');

		if (c.type == "pause") {
			paused = true;
		} else if (c.type == "decision") {
			deciding = true;

			for (b in decideForm.buttons) {
				b.visible = false;
			}

			for (t in decideForm.texts) {
				t.visible = false;
			}

			decideForm.prompt.text = c.params[0];

			var currentButtonIndex:Int = 0;
			for (i in 1...c.params.length) {
				if (i % 2 == 1) continue;
				decideForm.buttons[currentButtonIndex].visible = true;
				decideForm.texts[currentButtonIndex].visible = true;
				decideForm.texts[currentButtonIndex].text = c.params[i];
				addChild(decideForm.sprite);
				currentButtonIndex++;
			}

		} else if (c.type == "goto") {
			for (ci in commands) {
				if (ci.params[0] == c.params[0]) {
					currentChar = ci.pos;
				}
			}
		}
	}

	function decisionClicked(e:MouseEvent):Void
	{
		var buttonIndex = decideForm.buttons.indexOf(e.currentTarget);
		for (c in commands) {
			if (c.pos + c.len + 1 == currentChar) {

				var commandStrings:Array<String> = c.params[2 + buttonIndex * 2].split(" ");
				var newC:Command = {};
				newC.type = commandStrings[0];
				newC.params = [commandStrings[1]];
				newC.len = 0;

				exec(newC);
				deciding = false;
				removeChild(decideForm.sprite);
			}
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
	?prompt:TextField,
	?buttons:Array<Sprite>,
	?texts:Array<TextField>
}
