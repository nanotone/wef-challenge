package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

import controls.*;

public class CouncilNode {

	public static var selectedNode:CouncilNode = null;

	private static var nodeColor:uint = 0xFFB060;
	private static var selectedNodeColor:uint = 0xFF0000;
	private static var relatedNodeColor:uint = 0xFF8080;

	private static var edgeColor:uint = 0x202020;
	private static var inboundEdgeColor:uint = 0x000000;
	private static var outboundEdgeColor:uint = 0xFFFFFF;
	private static var unrelatedEdgeColor:uint = 0xA0A0A0;

	private static function setSelectedNode(node:CouncilNode):void {
		if (node == selectedNode) { return; }
		var i:uint;
		var prevSelectedNode:CouncilNode = CouncilNode.selectedNode;
		CouncilNode.selectedNode = node;
		var otherNodeName:String;
		var otherNode:CouncilNode;
		if (prevSelectedNode != null) {
			prevSelectedNode.drawNode();
			for (i = 0; i < WEF.instance.nodes.length; i++) { // set all nodes to unrelated
				WEF.instance.nodes[i].setRelated(false);
			}
		}
		if (node != null) {
			node.drawNode();
			for (i = 0; i < node.outboundData.length; i++) {
				otherNodeName = node.outboundData[i].token;
				otherNode = WEF.instance.nodesByName[otherNodeName];
				otherNode.setRelated(true);
			}
			for (i = 0; i < WEF.instance.nodes.length; i++) {
				otherNode = WEF.instance.nodes[i];
				if (otherNode.hasEdgeTo(node)) { otherNode.setRelated(true); }
			}
		}
		node.drawNode();
		WEF.instance.updateEdges();
	}

	///////////////////////////////////////////////////////////////////////////////

	private var token:String;
	private var fullName:String;
	private var outboundData:Array;

	private var theta:Number;

	private var nodeRoot:Sprite;
	private var nodeShape:Shape;
	private var nameLabelContain:Sprite;
	private var nameLabel:Label;
	private var edges:Array = [];

	private var isRelated:Boolean = false;

	public function CouncilNode(nodeInfo:Object) {
		this.token = nodeInfo.token;
		this.fullName = nodeInfo.name;
		this.outboundData = nodeInfo.outbound;

		this.nodeRoot = new Sprite();
		this.nodeShape = new Shape();
		this.nodeRoot.addChild(this.nodeShape);

      this.nodeRoot.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nodeRoot.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeUnhover);
		WEF.instance.nodeLayer.addChild(this.nodeRoot);

		this.nameLabelContain = new Sprite();
		this.nameLabel = new Label(this.fullName, {'font': 'AndikaBasic', 'size': 11, 'width': 200});
		this.nameLabelContain.addChild(this.nameLabel);
		this.nameLabel.y = - this.nameLabel.height / 2;
		WEF.instance.textLayer.addChild(this.nameLabelContain);

		this.nameLabel.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nameLabel.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeHover);
	}

	// accessors

	public function getX():Number { return Config.RADIUS * Math.cos(this.theta); }
	public function getY():Number { return Config.RADIUS * Math.sin(this.theta); }

	public function hasEdgeTo(other:CouncilNode):Boolean {
		for (var i:uint = 0; i < outboundData.length; i++) {
			var outboundDatum:Object = outboundData[i];
			if (outboundDatum.token == other.token) { return true; }
		}
		return false;
	}

	// mutators

	public function setId(id:uint):void {
		this.theta = id * WEF.twoPi / WEF.instance.nodes.length;
		while (Math.abs(this.theta) > Math.PI + 0.01) {
			this.theta -= (this.theta > 0 ? WEF.twoPi : -WEF.twoPi);
		}
		if (-WEF.piOverTwo < theta && theta < WEF.piOverTwo) {
			this.nameLabelContain.x = this.getX();
			this.nameLabelContain.y = this.getY();
			this.nameLabelContain.rotation = theta * 180 / Math.PI;
			this.nameLabel.align = TextFormatAlign.RIGHT;
		}
		else {
			this.nameLabelContain.x = this.getX() * ((Config.RADIUS + 200) / Config.RADIUS);
			this.nameLabelContain.y = this.getY() * ((Config.RADIUS + 200) / Config.RADIUS);
			this.nameLabelContain.rotation = (theta + Math.PI) * 180 / Math.PI;
			this.nameLabel.align = TextFormatAlign.LEFT;
		}
		this.drawNode();
	}

	public function setRelated(value:Boolean):void {
		if (value != this.isRelated) {
			this.isRelated = value;
			this.drawNode();
		}
	}

	// event handlers

   private function onNodeHover(e:MouseEvent):void {
		CouncilNode.setSelectedNode(this);
	}
	private function onNodeUnhover(e:MouseEvent):void {
		var relatedObject:DisplayObject = e.relatedObject as DisplayObject;
		if (this.nodeRoot.contains(relatedObject) || this.nameLabelContain.contains(relatedObject)) {
			return;
		}
		if (CouncilNode.selectedNode == this) {
			CouncilNode.setSelectedNode(null);
		}
	}

	// graphics

	public function drawNode():void {
		var dThetaOver2:Number = WEF.twoPi / WEF.instance.nodes.length / 2;
		var angle1:Number = this.theta - dThetaOver2;
		var angle2:Number = this.theta;
		var angle3:Number = this.theta + dThetaOver2;
		var innerRadius:Number = Config.RADIUS;
		var outerRadius:Number = Config.RADIUS + 210;
		var OUTERRADIUS:Number = outerRadius / Math.cos(dThetaOver2);

		var color:uint = nodeColor;
		if (this == selectedNode) {
			color = selectedNodeColor;
		}
		else if (this.isRelated) {
			color = relatedNodeColor;
		}

		this.nodeShape.graphics.clear();
		this.nodeShape.graphics.lineStyle(1, 0x000000);
		this.nodeShape.graphics.moveTo (innerRadius * Math.cos(angle1), innerRadius * Math.sin(angle1));
		this.nodeShape.graphics.beginFill(color);
		this.nodeShape.graphics.lineTo (outerRadius * Math.cos(angle1), outerRadius * Math.sin(angle1));
		this.nodeShape.graphics.curveTo(OUTERRADIUS * Math.cos(angle2), OUTERRADIUS * Math.sin(angle2),
		                                outerRadius * Math.cos(angle3), outerRadius * Math.sin(angle3));
		this.nodeShape.graphics.lineTo (innerRadius * Math.cos(angle3), innerRadius * Math.sin(angle3));
		this.nodeShape.graphics.endFill();
	}


	public function updateOutboundEdges():void {
		var i:int;
		for (i = 0; i < edges.length; i++) {
			WEF.instance.edgeLayer.removeChild(edges[i]);
		}
		edges = [];
		for (i = 0; i < outboundData.length; i++) {
			var outboundDatum:Object = outboundData[i];
			var other:CouncilNode = WEF.instance.nodesByName[outboundDatum.token];
			var color:uint;
			if (CouncilNode.selectedNode == null) {
				color = edgeColor;
				if (outboundDatum.score < 0.5) { continue; } // enforce threshold for global view
			}
			else if (CouncilNode.selectedNode == this) {
				color = outboundEdgeColor;
			}
			else if (CouncilNode.selectedNode == other) {
				color = inboundEdgeColor;
			}
			else {
				continue;
				color = unrelatedEdgeColor;
			}
			var edge:Shape = new Shape();
			edge.graphics.clear();
			edge.graphics.lineStyle(1, color);
			edge.graphics.moveTo(this.getX(), this.getY());
			var dx:Number = other.getX() - this.getX();
			var dy:Number = other.getY() - this.getY();
			var ds:Number = Math.sqrt(dx*dx + dy*dy) / Config.RADIUS;

			var anchorX:Number = ((other.getX() + this.getX()) / 2.0 + 0*ds) / (1 + ds*10);
			var anchorY:Number = ((other.getY() + this.getY()) / 2.0 + 0*ds) / (1 + ds*10);
			edge.graphics.curveTo(anchorX, anchorY, other.getX(), other.getY());

			if (color == unrelatedEdgeColor) {
				WEF.instance.edgeLayer.addChildAt(edge, 0);
			}
			else {
				WEF.instance.edgeLayer.addChild(edge);
			}
			edges.push(edge);
		}
	}

}}

