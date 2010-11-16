package {

import flash.display.*;
import flash.events.*;
import flash.net.*;

[SWF(backgroundColor="#FFFFFF", width="800", height="600")]
public class WEF extends Sprite {

	public static const twoPi:Number = 2 * Math.PI;
	public static const piOverTwo:Number = 0.5 * Math.PI;

	public static var instance:WEF;

	[Embed(source='AndBasR.ttf', fontName='AndikaBasic', embedAsCFF='false')]
	private var __andika:Class;

	public var canvas:Sprite;
	public var nodeLayer:Sprite;
	public var edgeLayer:Sprite;
	public var textLayer:Sprite;

	public var nodes:Array = [];

	public var nodesByName:Object = {};

	public function WEF() {
		Debug.attachTo(this);
		WEF.instance = this;

		var node:CouncilNode;

		canvas = new Sprite();
		this.addChild(canvas);
		canvas.x = 300; canvas.y = 300;
		nodeLayer = new Sprite();
		edgeLayer = new Sprite();
		textLayer = new Sprite();
		canvas.addChild(edgeLayer);
		canvas.addChild(nodeLayer);
		canvas.addChild(textLayer);

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
		this.addEventListener(Event.ENTER_FRAME, update);
	}

	public function updateEdges():void {
		for (var i:uint = 0; i < nodes.length; i++) {
			nodes[i].updateOutboundEdges();
		}
	}


	public function update(event:Event):void {
		//Debug.log("aoeu");
	}
}}
