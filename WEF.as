package {

import flash.display.*;
import flash.events.*;
import flash.net.*;

import mx.core.BitmapAsset;

[SWF(backgroundColor="#FFFFFF", width="800", height="600")]
public class WEF extends Sprite {

	public static const twoPi:Number = 2 * Math.PI;
	public static const piOverTwo:Number = 0.5 * Math.PI;

	public static var instance:WEF;

	[Embed(source='AndBasR.ttf', fontName='AndikaBasic', embedAsCFF='false')]
	private var __andika:Class;

	[Embed(source="speech.png")]
	private var speechBubbleCls:Class;
	private var speechBubble:Bitmap;

	public var canvas:Sprite;
	public var nodeLayer:Sprite;
	public var edgeLayer:Sprite;
	public var textLayer:Sprite;
	public var secondary:Shape;
	public var commentLayer:Sprite;

	public var nodes:Array = [];

	public var nodesByName:Object = {};

	public function WEF() {
		Debug.attachTo(this);
		WEF.instance = this;

		speechBubble = new speechBubbleCls();
		speechBubble.scaleX = 0.1;
		speechBubble.scaleY = 0.1;

		var node:CouncilNode;

		canvas = new Sprite();
		this.addChild(canvas);
		canvas.x = 300; canvas.y = 300;
		nodeLayer = new Sprite();
		edgeLayer = new Sprite();
		textLayer = new Sprite();
		secondary = new Shape();
		commentLayer = new Sprite();
		canvas.addChild(edgeLayer);
		canvas.addChild(secondary);
		canvas.addChild(nodeLayer);
		canvas.addChild(textLayer);
		//canvas.addChild(speechBubble);
		canvas.addChild(commentLayer);

		var i:uint;

		var categoryId:uint = 0;
		for (var categoryName:String in Data.data) {
			var councilData:Array = Data.data[categoryName];
			for (i = 0; i < councilData.length; i++) {
				var datum:Object = councilData[i];
				node = new CouncilNode(categoryId, datum);
				nodesByName[datum.token] = node;
				nodes.push(node);
			}
			categoryId += 1;
		}

		for (i = 0; i < nodes.length; i++) {
			nodes[i].setId(i);
		}
		this.updateEdges();
		//this.addEventListener(Event.ENTER_FRAME, update);
	}

	public function newSpeechBubble():DisplayObject {
		return new Bitmap(speechBubble.bitmapData);
	}

	public function updateEdges():void {
		for (var i:uint = 0; i < nodes.length; i++) {
			nodes[i].updateOutboundEdges();
		}
	}

	public function drawSecondaryCenter(color:uint):void {
		secondary.graphics.clear();
		secondary.graphics.beginFill(color);
		secondary.graphics.drawCircle(0, 0, CouncilNode.RADIUS);
		secondary.graphics.beginFill(color * 3 / 2);
		secondary.graphics.drawCircle(0, 0, CouncilNode.R_SRC0);
		secondary.graphics.endFill();
	}

	public function update(event:Event):void {
		Debug.log("aoeu");
	}
}}
