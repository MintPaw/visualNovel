package ;

import openfl.display.Sprite;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;

	function new()
	{
		super();

		{ // Load text
			storyText = Assets.getText("assets/story/main.txt");
		}
	}
}
