package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

import controls.*;

public class CouncilNode {

	public static const RADIUS:uint = 171;
	public static const RADIUS2:uint = 416;

	public static const R_SRC0:uint = 134;//RADIUS - 30;
	public static const R_SRC1:uint = R_SRC0 - 6;

	public static const R_DST0:uint = RADIUS + 40;
	public static const R_DST1:uint = R_DST0 + 8;

	public static const SPEECH_BUBBLE_OFFSET_X:int = -6;
	public static const SPEECH_BUBBLE_OFFSET_Y:int = -21;

	public static var hoveredNode:CouncilNode = null;
	public static var selectedNode:CouncilNode = null;

	public static const colorSchemesByCategoryId:Array = [
		{zebra0: 0xFFF0DB, zebra1: 0xFFEBCF, selected: 0x925517, related: 0xD6AD60 }, // yellow
		{zebra0: 0xF7DAE0, zebra1: 0xEEC8D0, selected: 0x740728, related: 0xED346B }, // red
		{zebra0: 0xDFF5F8, zebra1: 0xD4F1F6, selected: 0x005E70, related: 0x25B5D5 }, // blue
		{zebra0: 0xD0E7E4, zebra1: 0xC1E0DC, selected: 0x006E66, related: 0x45BDAB }, // green
		{zebra0: 0xFFDDD0, zebra1: 0xF9CDBB, selected: 0x8A200A, related: 0xF25B38 } ]; // orange

	private static var defaultEdgeColor:uint = 0xC0C0C0;
	//private static var unrelatedEdgeColor:uint = 0xA0A0A0;

	private static var mutualArrowColor:uint = 0xFFFFFF;

	public static function setHoveredNode(node:CouncilNode):void {
		if (node == CouncilNode.hoveredNode) { return; }
		var i:uint;
		var prevHoveredNode:CouncilNode = CouncilNode.hoveredNode;
		CouncilNode.hoveredNode = node;
		var otherNodeName:String;
		var otherNode:CouncilNode;
		if (prevHoveredNode != null) {
			prevHoveredNode.drawNode();
			for (i = 0; i < WEF.instance.nodes.length; i++) { // set all nodes to unrelated
				WEF.instance.nodes[i].setRelated(0);
			}
		}
		if (node != null) {
			node.drawNode();
			for (i = 0; i < node.outboundData.length; i++) {
				otherNodeName = node.outboundData[i].token;
				otherNode = WEF.instance.nodesByName[otherNodeName];
				otherNode.setRelated(otherNode.isRelated + node.outboundData[i].score);
			}
			for (i = 0; i < WEF.instance.nodes.length; i++) {
				otherNode = WEF.instance.nodes[i];
				var value:Number = otherNode.hasEdgeTo(node);
				otherNode.setRelated(otherNode.isRelated + value);
			}
		}
		WEF.instance.updateEdges();
	}

	public static var mode:String = "_Countries";
	public static function toggleMode():void {
		mode = (mode == "_Countries" ? "_Orgs" : "_Countries");
	}

	public static function setSelectedNode(node:CouncilNode):void {
		//if (node == CouncilNode.selectedNode) { return; } // no-op
		if (node == CouncilNode.selectedNode) { node = null; } // no-op
		var i:uint;
		var prevSelectedNode:CouncilNode = CouncilNode.selectedNode;
		CouncilNode.selectedNode = node;

		var otherNodeName:String;
		var otherNode:CouncilNode;
		if (prevSelectedNode != null) {
			prevSelectedNode.drawNode();
			for (i = 0; i < WEF.instance.nodes.length; i++) {
				WEF.instance.nodes[i].setRelated(0);
			}
		}

		WEF.instance.clearSecondaryCenter();
		if (WEF.instance.secondaryLayer.numChildren) {
			WEF.instance.secondaryLayer.removeChildAt(0);
		}

		WEF.instance.backButtonSprite.visible = true;//(node != null);
		if (node != null) {
			node.drawNode();
			for (i = 0; i < node.outboundData.length; i++) {
				otherNodeName = node.outboundData[i].token;
				otherNode = WEF.instance.nodesByName[otherNodeName];
				otherNode.setRelated(0);
			}
			for (i = 0; i < WEF.instance.nodes.length; i++) {
				otherNode = WEF.instance.nodes[i];
				var value:Number = otherNode.hasEdgeTo(node);
				otherNode.setRelated(otherNode.isRelated + value);
			}
			WEF.instance.drawSecondaryCenter(colorSchemesByCategoryId[node.categoryId].selected);

			mode = "_Countries";
			var circles:Circles = new Circles();
			var circle:DisplayObject = new (circles[CouncilNode.selectedNode.token + mode])() as DisplayObject;
			WEF.instance.secondaryLayer.addChild(circle);
		}
	}

	///////////////////////////////////////////////////////////////////////////////

	private var categoryId:uint;
	public var token:String;
	private var fullName:String;
	private var outboundData:Array;

	private var id:uint;
	private var theta:Number;
	private var isRelated:Number = 0;

	// visuals
	private var nodeRoot:Sprite;
	private var nodeShape:Shape;
	private var nameLabelContain:Sprite;
	private var nameLabel:Label;
	private var edges:Array = [];

	private var srcSpeechBubble:Sprite = null;
	private var dstSpeechBubble:Sprite = null;

	public function CouncilNode(categoryId:uint, nodeInfo:Object) {
		this.categoryId = categoryId;
		this.token = nodeInfo.token;
		this.fullName = nodeInfo.name;
		this.outboundData = nodeInfo.outbound;

		this.nodeRoot = new Sprite();
		this.nodeShape = new Shape();
		this.nodeRoot.addChild(this.nodeShape);

		this.nodeRoot.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nodeRoot.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeUnhover);
		this.nodeRoot.addEventListener(MouseEvent.CLICK, this.onClickNode);
		WEF.instance.nodeLayer.addChild(this.nodeRoot);

		this.nameLabelContain = new Sprite();
		this.nameLabel = new Label(this.fullName, {'font': 'AndikaBasic', 'size': 13, 'width': 200});
		this.nameLabelContain.addChild(this.nameLabel);
		this.nameLabel.y = - this.nameLabel.height / 2;
		WEF.instance.textLayer.addChild(this.nameLabelContain);

		this.nameLabel.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.nameLabel.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeHover);
		this.nameLabel.addEventListener(MouseEvent.CLICK, this.onClickNode);
	}

	// accessors

	public function getX():Number { return RADIUS * Math.cos(this.theta); }
	public function getY():Number { return RADIUS * Math.sin(this.theta); }

	public function hasEdgeTo(other:CouncilNode):Number {
		for (var i:uint = 0; i < outboundData.length; i++) {
			var outboundDatum:Object = outboundData[i];
			if (outboundDatum.token == other.token) { return outboundDatum.score; }
		}
		return 0;
	}

	// mutators

	public function setId(id:uint):void {
		this.id = id;
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
			this.nameLabelContain.x = this.getX() * ((RADIUS + 200) / RADIUS);
			this.nameLabelContain.y = this.getY() * ((RADIUS + 200) / RADIUS);
			this.nameLabelContain.rotation = (theta + Math.PI) * 180 / Math.PI;
			this.nameLabel.align = TextFormatAlign.LEFT;
		}
		this.drawNode();
	}

	public function setRelated(value:Number):void {
		this.isRelated = value;
		this.drawNode();
	}

	// event handlers

   private function onNodeHover(e:MouseEvent):void {
		if (CouncilNode.selectedNode != null) { return; }
		CouncilNode.setHoveredNode(this);
	}
	private function onNodeUnhover(e:MouseEvent):void {
		if (CouncilNode.selectedNode != null) { return; }
		var relatedObject:DisplayObject = e.relatedObject as DisplayObject;
		if (this.nodeRoot.contains(relatedObject) || this.nameLabelContain.contains(relatedObject)) {
			return;
		}
		if (CouncilNode.hoveredNode == this) {
			CouncilNode.setHoveredNode(null);
		}
	}
	private function onClickNode(e:MouseEvent):void {
		CouncilNode.setHoveredNode(null);
		CouncilNode.setSelectedNode(this);
		// oh snap
	}

	// graphics

	public function drawNode():void {
		var dThetaOver2:Number = WEF.twoPi / WEF.instance.nodes.length / 2;
		var angle1:Number = this.theta - dThetaOver2;
		var angle2:Number = this.theta;
		var angle3:Number = this.theta + dThetaOver2;
		var innerRadius:Number = RADIUS;
		var outerRadius:Number = RADIUS2;
		var OUTERRADIUS:Number = outerRadius / Math.cos(dThetaOver2);

		var originalColor:uint = colorSchemesByCategoryId[this.categoryId]["zebra" + (this.id % 2 ? "0":"1")];
		var color:uint;
		if (this == CouncilNode.hoveredNode || this == CouncilNode.selectedNode) {
			color = colorSchemesByCategoryId[this.categoryId].selected;
		}
		else if (this.isRelated > 0) {
			color = colorSchemesByCategoryId[this.categoryId].related;
		}
		else {
			/*var r1:uint = (color >> 16) % 256;
			var g1:uint = (color >>  8) % 256;
			var b1:uint = (color      ) % 256;
			var r2:uint = (originalColor >> 16) % 256;
			var g2:uint = (originalColor >>  8) % 256;
			var b2:uint = (originalColor      ) % 256;

			var score:Number = this.isRelated;
			if (score < 0.01) { score = 0.01; }
			if (score > 0.99) { score = 0.99; }
			r1 = int(r1*score + r2*(1 - score));
			g1 = int(g1*score + g2*(1 - score));
			b1 = int(b1*score + b2*(1 - score));
			color = (r1 << 16) + (g1 << 8) + (b1);*/
			color = originalColor;
		}

		var nodeGfx:Graphics = this.nodeShape.graphics;
		nodeGfx.clear();
		//nodeGfx.lineStyle(1, 0x000000);
		nodeGfx.moveTo (innerRadius * Math.cos(angle1), innerRadius * Math.sin(angle1));
		nodeGfx.beginFill(color);
		nodeGfx.lineTo (outerRadius * Math.cos(angle1), outerRadius * Math.sin(angle1));
		nodeGfx.curveTo(OUTERRADIUS * Math.cos(angle2), OUTERRADIUS * Math.sin(angle2),
		                                outerRadius * Math.cos(angle3), outerRadius * Math.sin(angle3));
		nodeGfx.lineTo (innerRadius * Math.cos(angle3), innerRadius * Math.sin(angle3));
		nodeGfx.endFill();

		if (CouncilNode.selectedNode != null) {
			var toSelected:Boolean = (this.hasEdgeTo(CouncilNode.selectedNode) > 0);
			var fromSelected:Boolean = (CouncilNode.selectedNode.hasEdgeTo(this) > 0);
			var smallRadius:Number;
			var SMALLRADIUS:Number;
			if (toSelected && !fromSelected) {
				nodeGfx.moveTo (innerRadius * Math.cos(angle1), innerRadius * Math.sin(angle1));
				nodeGfx.beginFill(color);
				nodeGfx.lineTo (R_SRC0 * Math.cos(angle1), R_SRC0 * Math.sin(angle1));
				nodeGfx.lineTo (R_SRC1 * Math.cos(angle2), R_SRC1 * Math.sin(angle2));
				nodeGfx.lineTo (R_SRC0 * Math.cos(angle3), R_SRC0 * Math.sin(angle3));
				nodeGfx.lineTo (innerRadius * Math.cos(angle3), innerRadius * Math.sin(angle3));
				nodeGfx.endFill();
			}
			else if (fromSelected && !toSelected) {
				color = colorSchemesByCategoryId[ CouncilNode.selectedNode.categoryId ].selected;
				nodeGfx.moveTo (innerRadius * Math.cos(angle1), innerRadius * Math.sin(angle1));
				nodeGfx.beginFill(color);
				nodeGfx.lineTo (R_DST0 * Math.cos(angle1), R_DST0 * Math.sin(angle1));
				nodeGfx.lineTo (R_DST1 * Math.cos(angle2), R_DST1 * Math.sin(angle2));
				nodeGfx.lineTo (R_DST0 * Math.cos(angle3), R_DST0 * Math.sin(angle3));
				nodeGfx.lineTo (innerRadius * Math.cos(angle3), innerRadius * Math.sin(angle3));
				nodeGfx.endFill();
			}
			else if (toSelected && fromSelected) {
				color = mutualArrowColor;
				nodeGfx.moveTo (R_SRC0 * Math.cos(angle1), R_SRC0 * Math.sin(angle1));
				nodeGfx.beginFill(color);
				nodeGfx.lineTo (R_SRC1 * Math.cos(angle2), R_SRC1 * Math.sin(angle2));
				nodeGfx.lineTo (R_SRC0 * Math.cos(angle3), R_SRC0 * Math.sin(angle3));
				nodeGfx.lineTo (R_DST0 * Math.cos(angle3), R_DST0 * Math.sin(angle3));
				nodeGfx.lineTo (R_DST1 * Math.cos(angle2), R_DST1 * Math.sin(angle2));
				nodeGfx.lineTo (R_DST0 * Math.cos(angle1), R_DST0 * Math.sin(angle1));
				nodeGfx.endFill();
			}
			// and now for the comments
			var commentKey:String;
			if (toSelected) {
				commentKey = this.token + "-" + CouncilNode.selectedNode.token;
				if (Data.data.comments.hasOwnProperty(commentKey)) { // actually have comment?
					if (srcSpeechBubble == null) {
						srcSpeechBubble = new Sprite();
						srcSpeechBubble.addChild(WEF.instance.newSpeechBubble());
						srcSpeechBubble.addEventListener(MouseEvent.MOUSE_OVER, this.onHoverSrcBubble);
						srcSpeechBubble.addEventListener(MouseEvent.MOUSE_OUT, this.onUnhoverSrcBubble);
					}
					srcSpeechBubble.x = R_SRC0 * Math.cos(angle2);
					srcSpeechBubble.y = R_SRC0 * Math.sin(angle2);
					WEF.instance.commentLayer.addChild(srcSpeechBubble); // TODO: sort
					srcSpeechBubble.name = commentKey;
				}
			}
			else if (srcSpeechBubble != null) {
				if (WEF.instance.commentLayer.contains(srcSpeechBubble)) {
					WEF.instance.commentLayer.removeChild(srcSpeechBubble);
				}
			}
			if (fromSelected) {
				commentKey = CouncilNode.selectedNode.token + "-" + this.token;
				if (Data.data.comments.hasOwnProperty(commentKey)) { // actually have comment?
					if (dstSpeechBubble == null) {
						dstSpeechBubble = new Sprite();
						dstSpeechBubble.addChild(WEF.instance.newSpeechBubble());
						dstSpeechBubble.addEventListener(MouseEvent.MOUSE_OVER, this.onHoverDstBubble);
						dstSpeechBubble.addEventListener(MouseEvent.MOUSE_OUT, this.onUnhoverDstBubble);
					}
					dstSpeechBubble.x = R_DST0 * Math.cos(angle2);
					dstSpeechBubble.y = R_DST0 * Math.sin(angle2);
					WEF.instance.commentLayer.addChild(dstSpeechBubble); // TODO: sort
					dstSpeechBubble.name = commentKey;
				}
			}
			else if (dstSpeechBubble != null) {
				if (WEF.instance.commentLayer.contains(dstSpeechBubble)) {
					WEF.instance.commentLayer.removeChild(dstSpeechBubble);
				}
			}
		}
		else {
			if (srcSpeechBubble != null) {
				if (WEF.instance.commentLayer.contains(srcSpeechBubble)) {
					WEF.instance.commentLayer.removeChild(srcSpeechBubble);
				}
			}
			if (dstSpeechBubble != null) {
				if (WEF.instance.commentLayer.contains(dstSpeechBubble)) {
					WEF.instance.commentLayer.removeChild(dstSpeechBubble);
				}
			}
		}
	}

	private function onHoverSrcBubble(e:MouseEvent):void {
		var comment:String = Data.data.comments[e.currentTarget.name];
		WEF.instance.showComment(srcSpeechBubble.x, srcSpeechBubble.y, comment);
	}
	private function onHoverDstBubble(e:MouseEvent):void {
		var comment:String = Data.data.comments[e.currentTarget.name];
		WEF.instance.showComment(dstSpeechBubble.x, dstSpeechBubble.y, comment);
	}
	private function onUnhoverSrcBubble(e:MouseEvent):void {
		WEF.instance.hideComment();
	}
	private function onUnhoverDstBubble(e:MouseEvent):void {
		WEF.instance.hideComment();
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
			if (CouncilNode.hoveredNode == null) {
				if (outboundDatum.score < 0.6) { continue; } // enforce threshold for global view
				color = defaultEdgeColor;
			}
			else if (CouncilNode.hoveredNode == this) {
				color = colorSchemesByCategoryId[this.categoryId].selected;
			}
			else if (CouncilNode.hoveredNode == other) {
				color = colorSchemesByCategoryId[this.categoryId].related;
			}
			else {
				continue;
				//color = unrelatedEdgeColor;
			}
			var edge:Shape = new Shape();
			edge.graphics.clear();
			edge.graphics.lineStyle(2, color, outboundDatum.score);
			edge.graphics.moveTo(this.getX(), this.getY());
			var dx:Number = other.getX() - this.getX();
			var dy:Number = other.getY() - this.getY();
			var ds:Number = Math.sqrt(dx*dx + dy*dy) / RADIUS;

			var anchorX:Number = ((other.getX() + this.getX()) / 2.0 + 0*ds) / (1 + ds*10);
			var anchorY:Number = ((other.getY() + this.getY()) / 2.0 + 0*ds) / (1 + ds*10);
			edge.graphics.curveTo(anchorX, anchorY, other.getX(), other.getY());

			/*if (color == unrelatedEdgeColor) { // should never need to make this distinction
				WEF.instance.edgeLayer.addChildAt(edge, 0);
			}
			else {
				WEF.instance.edgeLayer.addChild(edge);
			}*/
			WEF.instance.edgeLayer.addChild(edge);
			edges.push(edge);
		}
	}

}}

