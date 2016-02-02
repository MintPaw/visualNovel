package ;

import openfl.display.Sprite;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;
	var lables:Map<String, Int> = new Map();

	function new() {
		super();

		var labelReg:EReg = new EReg("(label.*)", "ig");
		storyText = Assets.getText("assets/story/main.txt");

		var lableSplits:Array<String> = labelReg.split(storyText);

	}

	function update():Void
	{
		// Maybe I'll use regex. >_>
		var skipChars:Int = 0;
		for (i in 0...storyText.length) {
			var c:String = storyText.charAt(i);

			if (skipChars > 0) {
				skipChars--;
			} else if (c == "/") {
				skipChars = 1;
			} else if (c == "(") {
				// skipChars = exec(i);
			}
		}
	}
}
