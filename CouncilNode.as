package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

import controls.*;

public class CouncilNode {

	public static var selectedNode:CouncilNode = null;

	private static var nodeColor:uint = 0xFFB060;
	private static var selectedNodeColor:uint = 0xFF0000;

	private static var edgeColor:uint = 0x202020;
	private static var inboundEdgeColor:uint = 0x000000;
	private static var outboundEdgeColor:uint = 0xFFFFFF;
	private static var unrelatedEdgeColor:uint = 0xA0A0A0;

	private var wef:WEF;
	private var fullName:String;
	private var outboundData:Array;

	private var theta:Number;

	private var nodeRoot:Sprite;
	private var nodeShape:Shape;
	private var nameLabelContain:Sprite;
	private var nameLabel:Label;
	private var edges:Array = [];

	public function CouncilNode(wef:WEF, nodeInfo:Object) {
		this.wef = wef;
		this.fullName = nodeInfo.name;
		this.outboundData = nodeInfo.outbound;

		this.nodeRoot = new Sprite();
		this.nodeShape = new Shape();
		this.nodeRoot.addChild(this.nodeShape);

      this.nodeRoot.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nodeRoot.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeUnhover);
		this.wef.nodeLayer.addChild(this.nodeRoot);

		this.nameLabelContain = new Sprite();
		this.nameLabel = new Label(this.fullName, {'font': 'AndikaBasic', 'size': 11, 'width': 200});
		this.nameLabelContain.addChild(this.nameLabel);
		this.nameLabel.y = - this.nameLabel.height / 2;
		this.wef.textLayer.addChild(this.nameLabelContain);

		this.nameLabel.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nameLabel.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeHover);
	}

	private static var drawn:Boolean = false;
	public function drawNode():void {
		var dThetaOver2:Number = WEF.twoPi / WEF.nNodes / 2;
		var angle1:Number = this.theta - dThetaOver2;
		var angle2:Number = this.theta;
		var angle3:Number = this.theta + dThetaOver2;
		var innerRadius:Number = Config.RADIUS;
		var outerRadius:Number = Config.RADIUS + 210;
		var OUTERRADIUS:Number = outerRadius / Math.cos(dThetaOver2);

		this.nodeShape.graphics.clear();
		this.nodeShape.graphics.lineStyle(1, 0x000000);
		this.nodeShape.graphics.moveTo (innerRadius * Math.cos(angle1), innerRadius * Math.sin(angle1));
		this.nodeShape.graphics.beginFill(this == selectedNode ? selectedNodeColor : nodeColor);
		this.nodeShape.graphics.lineTo (outerRadius * Math.cos(angle1), outerRadius * Math.sin(angle1));
		this.nodeShape.graphics.curveTo(OUTERRADIUS * Math.cos(angle2), OUTERRADIUS * Math.sin(angle2),
		                                outerRadius * Math.cos(angle3), outerRadius * Math.sin(angle3));
		this.nodeShape.graphics.lineTo (innerRadius * Math.cos(angle3), innerRadius * Math.sin(angle3));
		this.nodeShape.graphics.endFill();
	}

	public function setTheta(theta:Number):void {
		while (Math.abs(theta) > Math.PI + 0.01) {
			theta -= (theta > 0 ? WEF.twoPi : -WEF.twoPi);
		}
		this.theta = theta;
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

	public function getX():Number { return Config.RADIUS * Math.cos(this.theta); }
	public function getY():Number { return Config.RADIUS * Math.sin(this.theta); }

   private function onNodeHover(e:MouseEvent):void {
		if (this != CouncilNode.selectedNode) {
			var prevSelectedNode:CouncilNode = CouncilNode.selectedNode;
			CouncilNode.selectedNode = this;
			if (prevSelectedNode != null) {
				prevSelectedNode.drawNode();
			}
			this.drawNode();
			this.wef.updateEdges();
		}
	}
	private function onNodeUnhover(e:MouseEvent):void {
		var relatedObject:DisplayObject = e.relatedObject as DisplayObject;
		if (this.nodeRoot.contains(relatedObject) || this.nameLabelContain.contains(relatedObject)) {
			return;
		}
		if (CouncilNode.selectedNode == this) {
			CouncilNode.selectedNode = null;
		}
		this.drawNode();
		this.wef.updateEdges();
	}

	public function updateOutboundEdges():void {
		var i:int;
		for (i = 0; i < edges.length; i++) {
			wef.edgeLayer.removeChild(edges[i]);
		}
		edges = [];
		for (i = 0; i < outboundData.length; i++) {
			var other:CouncilNode = wef.nodesByName[outboundData[i]];
			var color:uint;
			if (CouncilNode.selectedNode == null) {
				color = edgeColor;
			}
			else if (CouncilNode.selectedNode == this) {
				color = outboundEdgeColor;
			}
			else if (CouncilNode.selectedNode == other) {
				color = inboundEdgeColor;
			}
			else {
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
				wef.edgeLayer.addChildAt(edge, 0);
			}
			else {
				wef.edgeLayer.addChild(edge);
			}
			edges.push(edge);
		}
	}

}}

