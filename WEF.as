package {

import flash.display.*;
import flash.events.*;
import flash.net.*;

[SWF(backgroundColor="#C0C0C0", width="800", height="600")]
public class WEF extends Sprite {

	public static const twoPi:Number = 2 * 3.14159265358979323;

	[Embed(source='AndBasR.ttf', fontName='AndikaBasic', embedAsCFF='false')]
	private var __andika:Class;

	public var canvas:Sprite;
	public var nodeLayer:Sprite;
	public var edgeLayer:Sprite;
	public var textLayer:Sprite;

	private var nodes:Array = [];

	public var nodesByName:Object = {};

	public function WEF() {
		Debug.attachTo(this);

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

		for (var key:String in Data.data) {
			node = new CouncilNode(this, Data.data[key]);
			nodesByName[key] = node;
			nodes.push(node);
		}

		var i:int;
		for (i = 0; i < nodes.length; i++) {
			node = nodes[i];
			node.setPosition(Config.RADIUS * Math.cos(i * twoPi / nodes.length),
			                 Config.RADIUS * Math.sin(i * twoPi / nodes.length) );
		}
		this.updateEdges();
		this.addEventListener(Event.ENTER_FRAME, update);
	}

	public function updateEdges():void {
		for (var i:uint = 0; i < nodes.length; i++) {
			var node:CouncilNode = nodes[i];
			node.updateOutboundEdges();
		}
	}


	public function update(event:Event):void {
		//Debug.log("aoeu");
	}
}}
