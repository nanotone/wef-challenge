package {

import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.text.*;

import controls.*;

[SWF(backgroundColor="#FFFFFF", width="1600", height="1000")]
public class WEF extends Sprite {

	public static const twoPi:Number = 2 * Math.PI;
	public static const piOverTwo:Number = 0.5 * Math.PI;

	public static var instance:WEF;

	//[Embed(source='AndBasR.ttf', fontName='AndikaBasic', embedAsCFF='false')]
	[Embed(source="embed/HelveticaNeue.otf", fontName="AndikaBasic", embedAsCFF="false")]
	private var __andika:Class;

	[Embed(source="embed/FINAL_BG_all.jpg")]
	private var bgCls:Class;

	[Embed(source="embed/speech.png")]
	private var speechBubbleCls:Class;
	private var speechBubble:Bitmap;

	[Embed(source="embed/BackButton.png")]
	private var backButtonCls:Class;
	private var backButton:Bitmap;
	public var backButtonSprite:Sprite;

	public var canvas:Sprite;
	public var nodeLayer:Sprite;
	public var edgeLayer:Sprite;
	public var textLayer:Sprite;
	public var secondary:Shape;
	public var secondaryLayer:Sprite;
	public var commentLayer:Sprite;
	public var buttonsLayer:Sprite;
	public var buttons:Shape;

	public var commentLayer2:Sprite; // the black popup
	public var commentShape:Shape;
	public var commentTitle:Label;
	public var commentField:TextField;

	public var nodes:Array = [];

	public var nodesByName:Object = {};


	public function onClickBackButton(e:MouseEvent):void {
		CouncilNode.setHoveredNode(null);
		CouncilNode.setSelectedNode(null);
		backButtonSprite.visible = false;
	}

	public function WEF() {
		Debug.attachTo(this);
		WEF.instance = this;

		speechBubble = new speechBubbleCls();
		speechBubble.scaleX = 0.1;
		speechBubble.scaleY = 0.1;

		var node:CouncilNode;

		var bg:DisplayObject = new bgCls();
		var bgSprite:Sprite = new Sprite();
		bgSprite.addChild(bg);
		this.addChild(bgSprite);

		backButtonSprite = new Sprite();
		backButton = new backButtonCls();
		backButtonSprite.addChild(backButton);
		backButtonSprite.addEventListener(MouseEvent.CLICK, this.onClickBackButton);
		backButtonSprite.x = 1250;
		backButtonSprite.y = 50;
		backButtonSprite.visible = false;
		backButtonSprite.buttonMode = true;
		backButtonSprite.useHandCursor = true;
		this.addChild(backButtonSprite);

		canvas = new Sprite();
		this.addChild(canvas);
		canvas.x = 800; canvas.y = 500;
		nodeLayer = new Sprite();
		edgeLayer = new Sprite();
		textLayer = new Sprite();
		secondary = new Shape();
		secondaryLayer = new Sprite();
		secondaryLayer.x = -306;
		secondaryLayer.y = -396;
		commentLayer = new Sprite();

		buttonsLayer = new Sprite();
		buttons = new Shape();
		buttons.graphics.clear();
		buttons.graphics.beginFill(0x808080, 0.0001);
		buttons.graphics.drawRoundRect(-60, 85, 120, 25, 15);
		buttons.graphics.endFill();
		buttonsLayer.addChild(buttons);
		buttonsLayer.addEventListener(MouseEvent.CLICK, this.onClickToggle);

		commentLayer2 = new Sprite();
		canvas.addChild(edgeLayer);
		canvas.addChild(secondary);
		canvas.addChild(secondaryLayer);
		canvas.addChild(buttonsLayer);
		canvas.addChild(nodeLayer);
		canvas.addChild(textLayer);
		canvas.addChild(commentLayer);
		//canvas.addChild(commentLayer2);

		commentLayer2 = new Sprite();
		commentShape = new Shape();
		commentLayer2.addChild(commentShape);
		commentTitle = new Label("WE WANT TO MEET THIS COUNCIL BECAUSE", {font: "AndikaBasic", size: 15, width: 280, color:0xA5A5A5, x:10, y:10});
		commentLayer2.addChild(commentTitle);
		commentField = new TextField();
		commentField.multiline = true;
		commentField.wordWrap = true;
		commentField.width = 280;
		commentField.height = 450;
		commentField.textColor = 0xFFFFFF;
		commentField.embedFonts = true;

		var format:TextFormat = commentField.defaultTextFormat;
		format.font = "AndikaBasic";
		format.size = 14;
		commentField.defaultTextFormat = format;
		commentField.setTextFormat(format);

		commentField.x = 10;
		commentField.y = 30;
		commentLayer2.addChild(commentField);
		

		var i:uint;

		var categoryId:uint = 0;
		var categoryNames:Array = [
			"Industry Agenda",
			"Risks and Opportunities",
			"Drivers and Trends",
			"Regional Agenda",
			"Policy and Institutional Responses"
		];
		for (var k:uint = 0; k < 5; k++) {
			var categoryName:String = categoryNames[k];
			var councilData:Array = Data.data.categoryExport[categoryName];
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

	public function onClickToggle(e:MouseEvent):void {
		if ((e.localX < 0) != (CouncilNode.mode == "_Countries")) {
			if (secondaryLayer.numChildren) {
				secondaryLayer.removeChildAt(0);
			}
			CouncilNode.toggleMode();
			var circles:Circles = new Circles();
			var circle:DisplayObject = new (circles[CouncilNode.selectedNode.token + CouncilNode.mode])() as DisplayObject;
			secondaryLayer.addChild(circle);
		}
	}

	public function newSpeechBubble():DisplayObject {
		var obj:DisplayObject = new Bitmap(speechBubble.bitmapData);
		obj.x = CouncilNode.SPEECH_BUBBLE_OFFSET_X;
		obj.y = CouncilNode.SPEECH_BUBBLE_OFFSET_Y;
		return obj;
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
	public function clearSecondaryCenter():void {
		secondary.graphics.clear();
	}

	public function showComment(x:Number, y:Number, text:String):void {
		commentField.htmlText = text;
		commentLayer2.x = x + 3;
		commentLayer2.y = y + 3;

		commentShape.graphics.beginFill(0x191919);
		commentShape.graphics.drawRoundRect(0, 0, 300, 150, 15);
		commentShape.graphics.endFill();

		canvas.addChild(commentLayer2);
	}
	public function hideComment():void {
		canvas.removeChild(commentLayer2);
	}

	public function update(event:Event):void {
		Debug.log("aoeu");
	}
}}
