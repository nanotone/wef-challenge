package controls {

import flash.errors.IllegalOperationError;
import flash.text.*;
import flash.utils.getQualifiedClassName;

public class UIText extends UISprite {

	private static var fonts:Object = null;

	protected var tf:TextField;
	protected var format:TextFormat;

	protected var _bgcolor:uint = 0;
	protected var _border:uint = 0;

	public function UIText(props:Object) {
		super(props);
		if (getQualifiedClassName(this) == "controls::UIText") {
			var msg:String = "controls.UIText cannot be instantiated.";
			Debug.log(msg);
			throw new IllegalOperationError(msg);
		}
	}

	public function get bgcolor():uint { return _bgcolor; }
	public function set bgcolor(value:uint):void {
		_bgcolor = value;
		tf.background = Boolean(value & 0xFF000000);
		tf.backgroundColor = (value & 0x00FFFFFF);
	}

	public function get border():uint { return _border; }
	public function set border(value:uint):void {
		_border = value;
		tf.border = Boolean(value & 0xFF000000);
		tf.borderColor = (value & 0x00FFFFFF);
	}

	public function get color():uint { return uint(format.color); }
	public function set color(value:uint):void {
		format.color = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get font():String { return format.font; }
	public function set font(value:String):void {
		if (value == null) { return; }
		format.font = value;
		//if (value == '' || Tools.startsWith(value, '_')) {
		if (value == '' || value.substr(0, 1) == "_") {
			tf.embedFonts = false;
		}
		else {
			if (fonts == null) {
				fonts = {};
				var fontObjs:Array = Font.enumerateFonts();
				for (var i:uint = 0; i < fontObjs.length; i++) {
					Debug.log("Adding " + fontObjs[i].fontName + " to font cache");
					fonts[fontObjs[i].fontName] = true;
				}
			}
			if (fonts.hasOwnProperty(value)) {
				tf.embedFonts = true;
			}
			else {
				Debug.log("WARNING: Missing embedded font " + value);
				format.font = '';
				tf.embedFonts = false;
			}
		}
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get leftMargin():int { return int(format.leftMargin); }
	public function set leftMargin(value:int):void {
		format.leftMargin = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get rightMargin():int { return int(format.rightMargin); }
	public function set rightMargin(value:int):void {
		format.rightMargin = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get size():uint { return uint(format.size); }
	public function set size(value:uint):void {
		format.size = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}


}}
