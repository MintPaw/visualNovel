package ;

import openfl.display.*;
import openfl.geom.*;
import openfl.text.*;
import openfl.events.*;
import openfl.ui.Keyboard;
import openfl.*;
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
	public var menu:PauseMenu;

	public var labels:Array<Label>;
	public var commands:Array<Command>;

	public var storyText:String;
	public var currentChar:Int;

	public var nextWordTime:Int;
	public var waitTime:Int;
	public var lastTime:Int;
	public var clearNext:Bool;
	public var speedUp:Bool;

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	public function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // setup menu
			menu = new PauseMenu();
			menu.x = stage.stageWidth / 2 - menu.width / 2;
			menu.y = stage.stageHeight / 2 - menu.height / 2;
			addChild(menu);
		}

		{ // parse story
			storyText = Assets.getText("story/main.txt");
			commands = [];
			labels = [];
			nextWordTime = 0;

			var inCommand:Bool = false;
			var currentCommand:Command = {};

			for (i in 0...storyText.length) {
				var c:String = storyText.charAt(i);
				if (c == "$" && !inCommand) {
					currentCommand = {};
					inCommand = true;
					currentCommand.pos = i;
					currentCommand.code = "";
				} else if (c == "$" && inCommand) {
					if (currentCommand.code.substr(0, 5) == "label") {
						var s:Int = currentCommand.code.indexOf("\"") + 1;
						var e:Int = currentCommand.code.indexOf("\"", s+1);

						var l:Label = {};
						l.name = currentCommand.code.substring(s, e);
						l.pos = i;
						labels.push(l);
					}

					inCommand = false;
					commands.push(currentCommand);
				} else if (inCommand) {
					currentCommand.code += c;
				}
			}

			// for (c in commands) trace(c);
			// for (l in labels) trace(l);
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
			decideForm.execCallback =
				function(c:Command) { state = "reading"; exec(c); };
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
		state = "reading";
		addChild(new openfl.display.FPS());

		graphics.lineStyle(1);
		interp.variables.set("Sprite", Sprite);
		interp.variables.set("Math", Math);
		interp.variables.set("stage", stage);
		interp.variables.set("story", this);
		interp.variables.set("speaking", speaking);
		interp.variables.set("addImage", scene.addImage);
		interp.variables.set("moveImage", scene.moveImage);
		interp.variables.set("removeImage", scene.removeImage);
		interp.variables.set("pause", pause);
		interp.variables.set("clear", clear);
		interp.variables.set("decision", decision);
		interp.variables.set("goto", goto);
		interp.variables.set("changeBg", scene.changeBg);
		interp.variables.set("wait", wait);
		interp.variables.set("fadeIn", fadeIn);
		interp.variables.set("fadeOut", fadeOut);
		interp.variables.set("label", label);

		addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(KeyboardEvent.KEY_UP, kUp);
		addEventListener(MouseEvent.MOUSE_DOWN, mDown);
		addEventListener(MouseEvent.MOUSE_UP, mUp);
		stage.focus = stage;
	}

	public function update(e:Event = null):Void {
		if (state == "done") return;

		var elapsed:Int = getTime() - lastTime;
		lastTime = getTime();

		if (waitTime > 0) {
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
			if (state == "deciding" || state == "paused" || state == "done")
				speedUp = false;
		}
	}

	public function updateStory():Void {
		if (clearNext) {
			clearNext = false;
			textField.text = "";
		}

		for (c in commands) {
			if (c.pos == currentChar) {
				currentChar += c.code.length + 2;
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

		if (currentChar >= storyText.length) state = "done";
	}

	public function exec(c:Command):Void {
		trace('Running $c');

		try {
			var expr = c.code;
			var ast = parser.parseString(expr);
			interp.execute(ast);
		} catch(e:hscript.Expr.Error) {
			trace("ERROR", e, c.code);
		}

  var doubleUpdateAfter:Array<String> =
			["addImage", "moveImage", "removeImage", "fadeOut", "fadeIn", "clear"];

		for (d in doubleUpdateAfter)
			if (c.code.substr(0, d.length) == d)
				updateStory();
	}

	public function kUp(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.SPACE) {
			if (state == "reading") speedUp = true;
			if (state == "paused") state = "reading";
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

	public function speaking(name:String = null):Void {
		titleField.visible = name != null;
		if (name != null) titleField.text = name;
	}

	public function pause():Void {
		state = "paused";
	}

	public function clear():Void {
		textField.text = "";
	}
	
	public function decision(prompt:String, rest:Array<String>):Void {
		state = "deciding";

		var prompt:String = prompt;
		var buttonLabels:Array<String> = [];
		var buttonParams:Array<String> = [];

		for (i in 0...rest.length) {
			if (i % 2 == 0) buttonLabels.push(rest[i]);
			if (i % 2 == 1) buttonParams.push(rest[i]);
		}

		decideForm.show(prompt, buttonLabels, buttonParams);
	}

	public function goto(loc:String):Void {
		for (ci in labels) if (loc == ci.name) currentChar = ci.pos + 1;
	}

	public function wait(ms:Int):Void {
		waitTime = ms;
	}

	public function fadeOut(colour:Int):Void {
		fader.graphics.clear();
		fader.graphics.beginFill(colour);
		fader.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		Actuate.tween(fader, 0.5, {alpha: 1});
	}

	public function fadeIn(colour:Int):Void {
		Actuate.tween(fader, 0.5, {alpha: 0});
	}

	public function label(name:String):Void {
		for (l in labels) {
			if (l.name == name) {
				trace('Macro label $name@${l.pos}');
				return;
			}
		}

		trace("FATAL MACRO ERROR");
	}

}

typedef Command = {
	?code:String,
	?pos:Int
}

typedef Label = {
	?name:String,
	?pos:Int
}
