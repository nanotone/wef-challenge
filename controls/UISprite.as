package controls {

import flash.display.*;
import flash.events.*;
import flash.geom.Rectangle;

import mx.events.ResizeEvent;
import mx.utils.StringUtil;

public class UISprite extends Sprite {

	public var id:String = null;

	protected var props:Object;

	protected var _cursor:String;
	protected var _scrollRect:Rectangle = new Rectangle(0, 0, 1234, 1234);

	protected var normalAttrs:Object;
	protected var hoverAttrs:Object = null;

	public function UISprite(_props:Object=null, applyImmediately:Boolean=false) {
		props = _props;
		if (applyImmediately) { applyAttributes(); }
	}

	protected function hasAttr(attr:String):Boolean {
		return props.hasOwnProperty(attr)
	}
	protected function getAttr(attr:String, elseVal:String=null):String {
		if (props.hasOwnProperty(attr)) {
			var value:String = props[attr];
			delete props[attr];
			return value;
		}
		return elseVal;
	}
	protected function getBoolean(attr:String, elseVal:Boolean=false):Boolean {
		var value:String = getAttr(attr);
		return (value != null ? (value.toLowerCase() == 'true') : elseVal);
	}
	protected function getNumber(attr:String, elseVal:Number=0):Number {
		var value:String = getAttr(attr);
		return (value != null ? Number(value) : elseVal);
	}

	protected function applyAttributes(attrList:Array = null):void {
		var attr:String;
		if (attrList != null) {
			for (var i:uint = 0; i < attrList.length; i++) {
				attr = attrList[i];
				if (props.hasOwnProperty(attr)) {
					applyAttribute(attr);
					delete props[attr];
				}
			}
		}
		else {
			for (attr in props) { applyAttribute(attr); }
			props = {}
		}
	}
	private function applyAttribute(attr:String):void {
		if (this.hasOwnProperty(attr)) {
			var oldValue:* = this[attr];
			var value:* = props[attr];
			if (oldValue is Boolean) {
				if (value is String) {
					value = (StringUtil.trim(value.toLowerCase()) == "true");
				}
			}
			else if (oldValue is Number) { value = Number(value); }
			else if (oldValue is    int) { value =    int(value); }
			else if (oldValue is   uint) { value =   uint(value); }
			this[attr] = value;
		}
		else {
			Debug.log("Attribute " + attr + " not applicable to " + this.toString());
		}
	}

	public override function getChildAt(index:int):DisplayObject {
		if (index < 0) { index += numChildren; }
		return super.getChildAt(index);
	}

	public function get cursor():String { return _cursor; }
	public function set cursor(value:String):void {
		_cursor = value;
		this.buttonMode = (value == "pointer");
		this.mouseChildren = (value == "select");
	}

	public function get sx():Number { return _scrollRect.x; }
	public function set sx(value:Number):void {
		_scrollRect.x = value;
		this.scrollRect = _scrollRect;
	}
	public function get sy():Number { return _scrollRect.y; }
	public function set sy(value:Number):void {
		_scrollRect.y = value;
		this.scrollRect = _scrollRect;
	}

	public function get swidth():Number { return _scrollRect.width; }
	public function set swidth(value:Number):void {
		_scrollRect.width = value;
		this.scrollRect = _scrollRect;
	}

	public function get sheight():Number { return _scrollRect.height; }
	public function set sheight(value:Number):void {
		_scrollRect.height = value;
		this.scrollRect = _scrollRect;
	}

	public function clearChildren():void {
		while (this.numChildren > 0) { this.removeChildAt(0); }
	}

	public function notifyResized():void {
		super.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
	}

	public function setHoverAttributes(attrs:Object = null):void {
		if (hoverAttrs != null) {
			this.removeEventListener(MouseEvent.MOUSE_OVER, this.onHover);
			this.removeEventListener(MouseEvent.MOUSE_OUT, this.onUnhover);
			this.onUnhover(null);
		}
		normalAttrs = {};
		hoverAttrs = attrs;
		if (attrs != null) {
			for (var key:String in attrs) { normalAttrs[key] = this[key]; }
			this.addEventListener(MouseEvent.MOUSE_OVER, this.onHover);
			this.addEventListener(MouseEvent.MOUSE_OUT, this.onUnhover);
		}
	}
	protected function onHover(e:Event):void {
		for (var key:String in hoverAttrs) { this[key] = hoverAttrs[key]; }
	}
	protected function onUnhover(e:Event):void {
		for (var key:String in normalAttrs) { this[key] = normalAttrs[key]; }
	}

}}
