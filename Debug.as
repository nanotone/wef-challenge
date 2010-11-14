package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

//import microthread.MicroThread;

public class Debug {

	public static const historyLength:uint = 29;

	private static var parent:DisplayObjectContainer = null;
	private static var contain:Sprite = null;
	private static var commandLine:TextField;
	private static var textFields:DisplayObjectContainer;

	public static function attachTo(_parent:DisplayObjectContainer):void {
		if (contain != null) { return; }
		if (Config.BUILD_TYPE != Config.BUILD_DEBUG) { return; }
		contain = new Sprite();
		contain.graphics.beginFill(0x000000);
		contain.graphics.drawRect(0, 0, Config.WIDTH, Config.HEIGHT);
		contain.graphics.endFill();
		contain.alpha = 0.6;
		commandLine = new TextField();
		commandLine.width = Config.WIDTH;
		commandLine.height = 18;
		commandLine.multiline = true;
		commandLine.textColor = 0xFFFFFF;
		commandLine.type = TextFieldType.INPUT;
		var format:TextFormat = commandLine.defaultTextFormat;
		format.font = "_typewriter";
		commandLine.defaultTextFormat = format;
		//commandLine.addEventListener(Event.CHANGE, onCommand);
		contain.addChild(commandLine);
		textFields = new Sprite();
		textFields.y = 20;
		contain.addChild(textFields);
		parent = _parent;
		parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		log("Debug created and attached to", parent);
	}

	public static function log(... args):void {
		if (Config.BUILD_TYPE != Config.BUILD_DEBUG) { return; }
		var textField:TextField = new TextField();
		if (textFields.numChildren > 0) {
			textField.y = textFields.getChildAt(textFields.numChildren - 1).y + 20;
		}
		textField.width = Config.WIDTH;
		textField.height = 18;
		textField.htmlText = '<font color="#FFFFFF" face="_typewriter">' +
			args.join(" ").replace(/&/g, "&amp;").replace(/</g, "&lt;") + "</font>";

		textFields.addChild(textField);
		while (textFields.numChildren > historyLength) {
			textFields.removeChildAt(0);
			textFields.y -= 20;
		}
	}

	/*private static function onCommand(e:Event):void {
		var text:String = commandLine.text;
		if (text.length > 0 && text.charCodeAt(text.length - 1) == 0x0D) {
			var tokens:Array = text.split(/\s+/);
			for (var i:uint = 0; i < tokens.length; i++) {
				if (tokens[i].length == 0) {
					tokens.splice(i, 1);
					i--;
				}
				else if (tokens[i].match(/^-?\d/)) {
					tokens[i] = Number(tokens[i]);
				}
				else if (tokens[i] == "true" || tokens[i] == "false") {
					tokens[i] = (tokens[i] == "true");
				}
				else if (tokens[i] == "null") {
					tokens[i] = null;
				}
			}
			new MicroThread(tokens, "Debug-" + Math.random());
			commandLine.text = "";
		}
	}*/

	private static function onKey(e:KeyboardEvent):void {
		if (e.keyCode != 0x30 || e.target == commandLine) { return; }
		if (!parent.contains(contain)) {
			parent.addChild(contain);
		}
		else {
			parent.removeChild(contain);
		}
	}

}}
