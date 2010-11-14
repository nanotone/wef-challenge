package {

import flash.display.*;
import flash.events.*;

public class CouncilNode {

	public static var selectedNode:CouncilNode = null;

	private var wef:WEF;
	private var nodeInfo:Array;

	private var root:Sprite;
	private var nodeShape:Shape;
	private var edges:Array = [];

	public function CouncilNode(wef:WEF, nodeInfo:Array) {
		this.wef = wef;
		this.nodeInfo = nodeInfo;

		this.root = new Sprite();
		this.nodeShape = new Shape();
		this.drawNode();
		this.root.addChild(this.nodeShape);

      this.root.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.root.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeUnhover);
		this.wef.nodeLayer.addChild(this.root);
	}

	public function drawNode():void {
		this.nodeShape.graphics.clear();
		var fillColor:uint = (this == selectedNode ? 0xFF0000 : 0xFFCC00);
		this.nodeShape.graphics.beginFill(fillColor);
		this.nodeShape.graphics.drawCircle(0, 0, 8);
		this.nodeShape.graphics.endFill();
	}

	public function setPosition(x:Number, y:Number):void {
		this.root.x = x;
		this.root.y = y;
	}
	public function getX():Number { return this.root.x; }
	public function getY():Number { return this.root.y; }

   private function onNodeHover(e:MouseEvent):void {
		CouncilNode.selectedNode = this;
		this.drawNode();
		//this.wef.updateEdges();
		//e.currentTarget as Node
	}
	private function onNodeUnhover(e:MouseEvent):void {
		if (CouncilNode.selectedNode == this) {
			CouncilNode.selectedNode = null;
		}
		this.drawNode();
	}


	public function updateOutboundEdges():void {
		var i:int;
		for (i = 0; i < edges.length; i++) {
			wef.edgeLayer.removeChild(edges[i]);
		}
		edges = [];
		for (i = 0; i < nodeInfo.length; i++) {
			var other:CouncilNode = wef.nodesByName[nodeInfo[i]];

			var edge:Shape = new Shape();
			edge.graphics.clear();
			edge.graphics.lineStyle(1, 0x000000);
			edge.graphics.moveTo(this.root.x, this.root.y);
			var dx:Number = other.getX() - nodeShape.x;
			var dy:Number = other.getY() - nodeShape.y;
			var ds:Number = Math.sqrt(dx*dx + dy*dy) / Config.RADIUS;

			var anchorX:Number = ((other.getX() + nodeShape.x) / 2.0 + 0*ds) / (1 + ds*10);
			var anchorY:Number = ((other.getY() + nodeShape.y) / 2.0 + 0*ds) / (1 + ds*10);
			edge.graphics.curveTo(anchorX, anchorY, other.getX(), other.getY());

			wef.edgeLayer.addChild(edge);
			edges.push(edge);
		}
	}

}}

