package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.Assets;
import motion.Actuate;

class Story extends Sprite
{
	public static var mouseDown:Bool;
	public static var parser = new hscript.Parser();
	public static var interp = new MintInterp();
	
	public var state:String = "";

	public var textField:TextField;
	public var titleField:TextField;
	public var decideForm:DecideForm;
	public var continueButton:Button;
	public var scene:Scene;
	public var fader:Sprite;

	public var commands:Array<Command>;

	public var storyText:String;
	public var currentChar:Int;

	public var nextWordTime:Int;
	public var waitTime:Int;
	public var lastTime:Int;
	public var clearNext:Bool;
	public var speedUp:Bool;
	public var done:Bool;

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	public function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // Get story
			storyText = Assets.getText("story/main.txt");
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

						if (c.type == "decision") {
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

			scene = new Scene();
			addChild(scene);

			var topPadding:Int = 30;
			var botPadding:Int = 30;
			var sidePadding:Int = 30;
			var innerPadding:Int = 20;

			continueButton =
				new Button("img/buttonUp.png", "img/buttonOver.png", "img/buttonDown.png",
						"continue");
			continueButton.x = stage.stageWidth - continueButton.width;
			continueButton.y = stage.stageHeight - continueButton.height;
			continueButton.onClick = function() { state = "reading"; };
			addChild(continueButton);


			decideForm = new DecideForm();
			decideForm.execCallback = exec;
			addChild(decideForm);

			textField = new TextField();
			textField.width = stage.stageWidth - (sidePadding * 2);
			textField.height = stage.stageHeight * 0.25;
			textField.x = sidePadding;
			textField.y = stage.stageHeight - textField.height - botPadding;
			textField.text = "";
			textField.border = true;
			textField.wordWrap = true;
			textField.embedFonts = true;
			textField.defaultTextFormat = new TextFormat("Open Sans", 14);
			addChild(textField);

			titleField = new TextField();
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.width = stage.stageWidth / 6;
			titleField.x = sidePadding;
			titleField.y = textField.y - botPadding;
			titleField.text = "TITLE";
			titleField.border = true;
			addChild(titleField);

			fader = new Sprite();
			fader.mouseEnabled = false;
			fader.mouseChildren = false;
			fader.alpha = 0;
			addChild(fader);
		}

		currentChar = 0;
		lastTime = getTime();
		stage.frameRate = 60;
		clearNext = false;
		mouseDown = false;
		done = false;
		state = "reading";
		addChild(new openfl.display.FPS());

		graphics.lineStyle(1);
		interp.variables.set("Sprite", Sprite);
		interp.variables.set("stage", stage);
		interp.variables.set("story", this);
		interp.variables.set("Math", Math);

		addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(KeyboardEvent.KEY_UP, kUp);
		addEventListener(MouseEvent.MOUSE_DOWN, mDown);
		addEventListener(MouseEvent.MOUSE_UP, mUp);
		stage.focus = stage;
	}

	public function update(e:Event = null):Void {
		var elapsed:Int = getTime() - lastTime;
		lastTime = getTime();

		if (waitTime >= 0) {
			trace(waitTime);
			waitTime -= elapsed;
			return;
		}

		if (state == "reading") {
			continueButton.visible = false;

			if (nextWordTime <= 0) {
				nextWordTime = 16;
				updateStory();
			} else {
				nextWordTime -= elapsed;
			}
		}

		if (state == "paused") {
			continueButton.visible = true;
			continueButton.update();
		}

		if (state == "deciding") decideForm.update();

		while (speedUp) {
			updateStory();
			if (state == "deciding" || state == "paused") speedUp = false;
		}
	}

	public function updateStory():Void {
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
			state = "paused";
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

		if (currentChar >= storyText.length) done = true;
	}

	public function exec(c:Command):Void {
		trace('Running $c');
		var p:Array<String> = c.params[0].split(" ");

		if (c.type == "pause") {
			state = "paused";
		} else if (c.type == "decision") {
			state = "deciding";

			var prompt:String = c.params[0];
			var buttonLabels:Array<String> = [];
			var buttonParams:Array<String> = [];

			for (i in 1...c.params.length) {
				if (i % 2 == 0) buttonParams.push(c.params[i]);
				if (i % 2 == 1) buttonLabels.push(c.params[i]);
			}

			decideForm.show(prompt, buttonLabels, buttonParams);

		} else if (c.type == "goto") {
			for (ci in commands) {
				if (ci.params[0] == c.params[0]) {
					currentChar = ci.pos;
				}
			}
		} else if (c.type == "changeBg") {
			scene.changeBg(c.params[0]);
		} else if (c.type == "speaking") {
			titleField.visible = c.params[0] != "NULL";
			titleField.text = c.params[0];
		} else if (c.type == "clear") {
			textField.text = "";
		} else if (c.type == "haxe") {
			var expr = c.params[0];
			var ast = parser.parseString(expr);
			interp.execute(ast);
		} else if (c.type == "addImage") {
			scene.addImage(p[0], p[1]);
		} else if (c.type == "moveImage") {
			scene.moveImage(p[0], Std.parseInt(p[1]), Std.parseInt(p[2]));
		} else if (c.type == "removeImage") {
			scene.removeImage(c.params[0]);
		} else if (c.type == "fadeOut") {
			fader.graphics.clear();
			fader.graphics.beginFill(Std.parseInt(p[0]));
			fader.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			Actuate.tween(fader, 0.5, {alpha: 1});
		} else if (c.type == "fadeIn") {
			Actuate.tween(fader, 0.5, {alpha: 0});
		} else if (c.type == "wait") {
			trace(p);
			waitTime = Std.parseInt(p[0]);
		} else {
			if (interp.variables.exists(c.type)) interp.variables.get(c.type)();
		}

		var doubleUpdateAfter:Array<String> =
			["addImage", "moveImage", "removeImage"];
		if (doubleUpdateAfter.indexOf(c.type) != -1) updateStory();
	}

	public function kUp(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.SPACE) {
			if (state == "paused") state = "reading" else speedUp = true;
		}
	}

	public function mDown(e:MouseEvent):Void {
		mouseDown = true;
	}

	public function mUp(e:MouseEvent):Void {
		mouseDown = false;
	}

	public function getTime():Int {
		return Std.int(haxe.Timer.stamp() * 1000);
	}

}

typedef Command = {
	?type:String,
	?params:Array<String>,
	?pos:Int,
	?len:Int
}
