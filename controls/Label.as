package controls {

import flash.display.*;
import flash.events.*;
import flash.text.*;

public class Label extends UIText {

	private var setWidth:Boolean;
	private var setHeight:Boolean = false;
	private var startIndex:int = -1;
	private var endIndex:int = -1;

	//private var _annotator:Annotator;

	public function Label(htmlText:String, props:Object) {
		super(props);
		tf = new TextField();
		tf.multiline = true;
		tf.wordWrap = true;
		this.cursor = 'select';
		this.addChild(tf);

		var uColor:int = getNumber('ulineColor', -1);
		var dictionary:Boolean = getBoolean('dictionary', false);
		var lookup:Boolean = getBoolean('lookup', true);
			
		//if (getAttr('lang') == Config.CHINESE) { _annotator = new ChineseAnnotator(tf, uColor, dictionary, lookup); }
		//else { _annotator = new Annotator(tf, uColor, dictionary, lookup); }
		//this.addChild(_annotator);
		format = tf.defaultTextFormat;

		super.applyAttributes(['bold', 'font', 'leading', 'letterSpacing', 'size', 'width']);
		this.text = htmlText;

		this.addEventListener(MouseEvent.MOUSE_UP, handleSelect);
		this.addEventListener(MouseEvent.MOUSE_OUT, handleSelect);
		super.applyAttributes();
	}

	//public function get annotator():Annotator { return _annotator; }

	public function get textField():TextField { return tf; }

	public function get align():String { return format.align; }
	public function set align(value:String):void {
		format.align = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get bold():Boolean { return format.bold; }
	public function set bold(value:Boolean):void {
		format.bold = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public override function set cursor(value:String):void {
		super.cursor = value;
		tf.selectable = this.mouseChildren;
	}

	public function get leading():int { return int(format.leading); }
	public function set leading(value:int):void {
		format.leading = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get letterSpacing():int { return int(format.letterSpacing); }
	public function set letterSpacing(value:int):void {
		format.letterSpacing = value;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}

	public function get selectable():Boolean { return tf.selectable; }
	public function set selectable(value:Boolean):void {
		tf.selectable = value;
	}

	public override function get width():Number { return tf.width; }
	public override function set width(value:Number):void {
		setWidth = true;
		tf.width = value;
	}
	public override function get height():Number { return tf.height; }
	public override function set height(value:Number):void {
		setHeight = true;
		tf.height = value;
	}

	public function get text():String { return tf.text; }
	public function set text(value:String):void {
		if (value == null) { value = ""; }
		var w:Number = tf.width;
		var h:Number = tf.height;
		if (!setWidth) {
			tf.width = 9001;
		}
		value = value.replace(/\r\n/g, "\n");
		value = value.replace(/[\r\n]/g, "\n");
		tf.htmlText = value; //_annotator.setHtmlText(value);
		if (!setWidth) {
			if (tf.getLineLength(0) == 0) {
				tf.width = 0;
			}
			else {
				var metrics:TextLineMetrics = tf.getLineMetrics(0);
				tf.width = /*metrics.x*/2 + metrics.width + 4;
			}
		}
		if (!setHeight) {
			tf.height = tf.numLines * tf.getLineMetrics(0).height + 4;
		}
		if (tf.width != w || tf.height != h) { notifyResized(); }
	}

	public function get textColor():uint { return tf.textColor; }
	public function set textColor(_color:uint):void { tf.textColor = _color; }

	public function handleSelect(e:Event):void {
		if (tf.selectionBeginIndex == startIndex && tf.selectionEndIndex == endIndex) {
			return;
		}
		//Debug.log('selection is: ' + tf.selectionBeginIndex + "||" + tf.selectionEndIndex);
		if (tf.selectionBeginIndex != tf.selectionEndIndex) {
			// we're not doing checking here because Underline does it
			//annotator.getCharSounds(tf.selectionBeginIndex, tf.selectionEndIndex);
		}
		startIndex = tf.selectionBeginIndex;
		endIndex = tf.selectionEndIndex;
	}
}
}
