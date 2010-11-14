package {

import flash.display.*;
import flash.events.*;
import flash.net.*;

/*import microthread.*;
import utils.*;
import controls.*;
*/

[SWF(backgroundColor="#808080", width="800", height="600")]
public class WEF extends Sprite {

	private static const twoPi:Number = 2 * 3.14159265358979323;

	public var canvas:Sprite;

	public var nodesByName:Object = {};

	public function WEF() {
		Debug.attachTo(this);

		var nodes:Array = [];

		var node:CouncilNode;

		canvas = new Sprite();
		this.addChild(canvas);
		canvas.x = 300; canvas.y = 300;

		for (var key:String in Data.data) {
			node = new CouncilNode(this, Data.data[key]);
			nodesByName[key] = node;
			nodes.push(node);
		}

		var i:int;
		for (i = 0; i < nodes.length; i++) {
			node = nodes[i];
			node.setPosition(100 * Math.cos(i * twoPi / nodes.length),
			                 100 * Math.sin(i * twoPi / nodes.length) );
		}
		for (i = 0; i < nodes.length; i++) {
			node = nodes[i];
			node.updateOutboundEdges();
		}

		this.addEventListener(Event.ENTER_FRAME, update);
	}


	public function update(event:Event):void {
		//Debug.log("aoeu");
	}
}}
