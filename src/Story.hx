package ;

import openfl.display.Sprite;
import openfl.text.TextField;
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
	var clearNext:Bool;

	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // Get story
			storyText = Assets.getText("assets/story/main.txt");
			commands = [{ type: "label", params: "main", pos: -1, len: 1 }];

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
						c.params = commandSubStrings.join(" ");
						c.pos = reg.matchedPos().pos;
						c.len = reg.matchedPos().len;
						commands.push(c);

						return commandString;
					});
		}

		{ // Setup UI
			var botPadding:Int = 30;
			var sidePadding:Int = 30;
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
		clearNext = false;
		addChild(new openfl.display.FPS());

		addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		stage.focus = stage;
	}

	function update(e:Event):Void {
		var elapsed:Int = getTime() - lastTime;
		lastTime = getTime();

		if (!paused) {
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
			// trace("d
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
	?params:String,
	?pos:Int,
	?len:Int
}
