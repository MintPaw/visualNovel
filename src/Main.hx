package;

import openfl.display.Sprite;

class Main extends Sprite {
	
	public function new() {
		super();

		trace("\n\n\n\n");
		var story:Story = new Story();
		addChild(story);
	}
}
