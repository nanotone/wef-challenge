package {

import flash.display.*;

public class CouncilNode {

	private var bgColor:uint = 0xFFCC00;

	private var wef:WEF;
	private var nodeInfo:Array;

	private var nodeShape:Shape;
	private var edges:Array = [];

	public function CouncilNode(wef:WEF, nodeInfo:Array) {
		this.wef = wef;
		this.nodeInfo = nodeInfo;
		nodeShape = new Shape();
		nodeShape.graphics.beginFill(bgColor);
		nodeShape.graphics.drawCircle(0, 0, 5);
		nodeShape.graphics.endFill();

		wef.canvas.addChild(nodeShape);
	}

	public function setPosition(x:Number, y:Number):void {
		nodeShape.x = x;
		nodeShape.y = y;
	}
	public function getX():Number { return nodeShape.x; }
	public function getY():Number { return nodeShape.y; }

	public function updateOutboundEdges():void {
		var i:int;
		for (i = 0; i < edges.length; i++) {
			wef.canvas.removeChild(edges[i]);
		}
		edges = [];
		for (i = 0; i < nodeInfo.length; i++) {
			var other:CouncilNode = wef.nodesByName[nodeInfo[i]];

			var edge:Shape = new Shape();
			edge.graphics.clear();
			edge.graphics.lineStyle(1, 0x000000);
			edge.graphics.moveTo(nodeShape.x, nodeShape.y);
			edge.graphics.curveTo(0, 0, other.getX(), other.getY());
			wef.canvas.addChild(edge);
			edges.push(edge);
		}
	}

}}

