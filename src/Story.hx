package ;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;
	var commands:Array<Command>;
	var textField:TextField;
	var currentChar:Int;
	var nextWordTime:Int;
	var lastTime:Int;

	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // Get story
			var reg:EReg = new EReg("\\(.*\\)", "ig");
			storyText = Assets.getText("assets/story/main.txt");

			commands = [{ type: "label", params: "main", pos: -1, len: 1 }];

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
			textField.text = "test";
			textField.border = true;
			addChild(textField);
		}

		currentChar = 0;
		lastTime = getTime();
		stage.frameRate = 60;
		addChild(new openfl.display.FPS());

		addEventListener(Event.ENTER_FRAME, update);
	}

	function update(e:Event):Void {
		var elapsed:Int = getTime() - lastTime;
		lastTime = getTime();

		if (nextWordTime <= 0) {
			nextWordTime = 16;
			updateStory();
		} else {
			nextWordTime -= elapsed;
		}
	}

	function updateStory():Void {
		for (c in commands) {
			if (c.pos == currentChar) {
				currentChar += c.len;
				exec(c);
			}
		}

		var char:String = storyText.charAt(currentChar);
		// trace(char, currentChar);

		textField.text += char;
		currentChar++;
	}

	function exec(c:Command):Void
	{
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
