package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

import controls.*;

public class CouncilNode {

	//public static var fonts:Object = null;

	public static var selectedNode:CouncilNode = null;

	private static var nodeColor:uint = 0xFF6000;
	private static var selectedNodeColor:uint = 0xFF0000;

	private static var edgeColor:uint = 0x202020;
	private static var inboundEdgeColor:uint = 0x000000;
	private static var outboundEdgeColor:uint = 0xFFFFFF;
	private static var unrelatedEdgeColor:uint = 0xA0A0A0;

	private var wef:WEF;
	private var fullName:String;
	private var outboundData:Array;

	private var root:Sprite;
	private var nodeShape:Shape;
	//private var nameLabel:TextField;
	private var nameLabel:Label;
	private var edges:Array = [];

	/*public static function setFont(tf:TextField, value:String):void {
		if (value == null) { return; }
		var format:TextFormat = tf.defaultTextFormat;
		format.font = value;
		if (value == "" || value.substr(0, 1) == "_") {
			tf.embedFonts = false;
		}
		else {
			if (fonts == null) {
				Debug.log("Creating fonts cache");
				fonts = {};
				var fontObjs:Array = Font.enumerateFonts();
				for (var i:uint = 0; i < fontObjs.length; i++) {
					Debug.log("Adding " + fontObjs[i].fontName + " to fonts cache");
					fonts[fontObjs[i].fontName] = true;
				}
			}
			if (fonts.hasOwnProperty(value)) {
				tf.embedFonts = true;
			}
			else {
				Debug.log("WARNING: missing embedded font " + value);
				format.font = "";
				tf.embedFonts = false;
			}
		}
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
	}*/

	public function CouncilNode(wef:WEF, nodeInfo:Object) {
		this.wef = wef;
		this.fullName = nodeInfo.name;
		this.outboundData = nodeInfo.outbound;

		this.root = new Sprite();
		this.nodeShape = new Shape();
		this.drawNode();
		this.root.addChild(this.nodeShape);

      this.root.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeHover);
		this.root.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeUnhover);
		this.wef.nodeLayer.addChild(this.root);

		this.nameLabel = new Label(this.fullName, {'font': 'AndikaBasic', 'size': 11});
		//this.nameLabel = new TextField();
		//setFont(this.nameLabel, "AndikaBasic");
		//this.nameLabel.text = this.fullName;
		this.wef.textLayer.addChild(this.nameLabel);
	}

	public function drawNode():void {
		this.nodeShape.graphics.clear();
		var fillColor:uint = (this == selectedNode ? 0xFF0000 : 0xE06000);
		this.nodeShape.graphics.beginFill(fillColor);
		this.nodeShape.graphics.drawCircle(0, 0, 8);
		this.nodeShape.graphics.endFill();
	}

	public function setPosition(x:Number, y:Number):void {
		this.root.x = x;
		this.root.y = y;
		this.nameLabel.x = x;
		this.nameLabel.y = y;
		this.nameLabel.width = 200;
		this.nameLabel.rotation = Math.atan2(y, x) * 180 / Math.PI;
	}
	public function getX():Number { return this.root.x; }
	public function getY():Number { return this.root.y; }

   private function onNodeHover(e:MouseEvent):void {
		CouncilNode.selectedNode = this;
		this.drawNode();
		this.wef.updateEdges();
	}
	private function onNodeUnhover(e:MouseEvent):void {
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
			edge.graphics.moveTo(this.root.x, this.root.y);
			var dx:Number = other.getX() - nodeShape.x;
			var dy:Number = other.getY() - nodeShape.y;
			var ds:Number = Math.sqrt(dx*dx + dy*dy) / Config.RADIUS;

			var anchorX:Number = ((other.getX() + nodeShape.x) / 2.0 + 0*ds) / (1 + ds*10);
			var anchorY:Number = ((other.getY() + nodeShape.y) / 2.0 + 0*ds) / (1 + ds*10);
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

