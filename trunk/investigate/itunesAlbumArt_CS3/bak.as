/*/
iTunes Album Art Viewer
/*/
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;

//**************************************************************
var albumInfoXML:String = "";
function loaderComplete(myEvent:Event)
{
	this.myParams=this.loaderInfo.parameters;
	this.myParamsLoaded=true;
	albumInfoXML = this.myParams.xmlURL;
}

var myLoaderInfo=new Object();
myLoaderInfo.myParamsLoaded=false;
myLoaderInfo.loaderComplete=loaderComplete;

this.loaderInfo.addEventListener(Event.COMPLETE, myLoaderInfo.loaderComplete);


//**************************************************************

//Change these values below to customize the viewer fuctionality
var root:MovieClip = this;
var myMO:Object;
var myKO:Object;
var loadedAll:Boolean;
var distance:Number;
var autoJump:Number = .15;
var maxSlide:Number = 100;
var deleteMinDistance:Number = 0;
var deleteMaxDistance:Number = 500;
var doubleClickRegister:Number = 500;
var frontCDWidth:Number = 150;
var frontCDHeight:Number = 150;
var shelveCDHeight:Number = 120;
var shelveCDWidth:Number = 80;
var shelveCDSpacing:Number = 50;
var centerDistance:Number = 50;
var albumEase:Number = 4;
var angle:Number = 8;
var fadePoint:Number = Stage.width;
var fadeDist:Number = 200;
var current:Number = 1;
var centerX:Number = Stage.width / 2;
var centerY:Number = 90;
var clickDelay:Number = 750;
var scrollBarStart:Number = 0;
var scrollerDelay:Number = 150;
var scrollBarStop:Number = scrollBar.scroller._width + 49;
var reflectionBackgroundColour:Number = 0x000000;
var reflectionBlurX:Number = 0;
var reflectionBlurY:Number = 0;
var reflectionQuality:Number = 3;
var reflectionSpace:Number = 0;
var reflectionAlpha:Number = 100;
var reflectionRotation:Number = 90;
var reflectionFocalPointRatio:Number = 0.3;
var reflectionFillType:String = "linear";
var reflectionSpreadMethod:String = "pad";
var reflectionInterpolationMethod:String = "RGB";
var unknownArtist:String = "Unknown Artist";
var unknownAlbum:String = "Unknown Album";
var infostruc:Array = [];
var reflectionColors:Array = [0x000000, 0x000000];
var reflectionAlphas:Array = [100, 10];
var reflectionRatios:Array = [0, 255];
var xmlData:XML = new XML();
MovieClip.prototype.setSides = function(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Void  {
	this.px1 = x1;
	this.py1 = y1;
	this.px2 = x2;
	this.py2 = y2;
	this.px3 = x3;
	this.py3 = y3;
	this.px4 = x4;
	this.py4 = y4;
};
MovieClip.prototype.DistortImage = function(ptexture, vseg:Number, hseg:Number) {
	if (ptexture instanceof BitmapData) {
		this.texture = ptexture;
	} else if (ptexture instanceof MovieClip) {
		this.texture = new BitmapData(ptexture._width, ptexture._height);
		this.texture.draw(ptexture);
	}
	this._w = this.texture.width;
	this._h = this.texture.height;
	this._aMcs = [];
	this._p = [];
	this._tri = [];
	this.init();
};
MovieClip.prototype.setTransform = function(x0:Number, y0:Number, x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number):Void  {
	this.dx30 = x3 - x0;
	this.dy30 = y3 - y0;
	this.dx21 = x2 - x1;
	this.dy21 = y2 - y1;
	for (var l in this._p) {
		this.point = this._p[l];
		var gx = (this.point.x - this._xMin) / this._w;
		var gy = (this.point.y - this._yMin) / this._h;
		var bx = x0 + gy * (this.dx30);
		var by = y0 + gy * (this.dy30);
		this.point.sx = bx + gx * ((x1 + gy * (this.dx21)) - bx);
		this.point.sy = by + gx * ((y1 + gy * (this.dy21)) - by);
	}
	this.render();
};
MovieClip.prototype.init = function(Void):Void  {
	this._p = [];
	this._tri = [];
	this.w2 = this._w / 2;
	this.h2 = this._h / 2;
	this._xMin = this._yMin = 0;
	this._xMax = this._w;
	this._yMax = this._h;
	this._hsLen = this._w / 2;
	this._vsLen = this._h / 2;
	for (ix = 0; ix < 3; ix++) {
		for (iy = 0; iy < 3; iy++) {
			x = ix * this._hsLen;
			y = iy * this._vsLen;
			this._p.push({x:x, y:y, sx:x, sy:y});
		}
	}
	for (ix = 0; ix < 2; ix++) {
		for (iy = 0; iy < 2; iy++) {
			this.p0 = this._p[iy + ix * 3];
			this.p1 = this._p[iy + ix * 3 + 1];
			this.p2 = this._p[iy + (ix + 1) * 3];
			this.addTriangle(this.p0,this.p1,this.p2);
			this.p0 = this._p[iy + (ix + 1) * 3 + 1];
			this.p1 = this._p[iy + (ix + 1) * 3];
			this.p2 = this._p[iy + ix * 3 + 1];
			this.addTriangle(this.p0,this.p1,this.p2);
		}
	}
	this.render();
};
MovieClip.prototype.addTriangle = function(p0:Object, p1:Object, p2:Object):Void  {
	this.tMat = {};
	this.u0 = p0.x;
	this.v0 = p0.y;
	this.u1 = p1.x;
	this.v1 = p1.y;
	this.u2 = p2.x;
	this.v2 = p2.y;
	this.tMat.tx = -this.v0 * (this._w / (this.v1 - this.v0));
	this.tMat.ty = -this.u0 * (this._h / (this.u2 - this.u0));
	this.tMat.a = this.tMat.d = 0;
	this.tMat.b = this._h / (this.u2 - this.u0);
	this.tMat.c = this._w / (this.v1 - this.v0);
	this._tri.push([p0, p1, p2, this.tMat]);
};
MovieClip.prototype.render = function(Void):Void  {
	this.clear();
	this.ih = 1 / this._h;
	this.iw = 1 / this._w;
	this.tM = this.sM = {};
	for (var l in this._tri) {
		a = this._tri[l];
		this.p0 = a[0];
		this.p1 = a[1];
		this.p2 = a[2];
		this.tM = a[3];
		this.sM.a = (this.p1.sx - (this.x0 = this.p0.sx)) * this.iw;
		this.sM.b = (this.p1.sy - (this.y0 = this.p0.sy)) * this.iw;
		this.sM.c = (this.p2.sx - this.x0) * this.ih;
		this.sM.d = (this.p2.sy - this.y0) * this.ih;
		this.sM.tx = this.x0;
		this.sM.ty = this.y0;
		this.sM = concat(this.sM, this.tM);
		this.beginBitmapFill(this.texture,this.sM,false,false);
		this.moveTo(this.x0,this.y0);
		this.lineTo(this.p1.sx,this.p1.sy);
		this.lineTo(this.p2.sx,this.p2.sy);
		this.endFill();
	}
};
function init(Void):Void {
	myMO = {};
	myKO = {};
	Mouse.addListener(myMO);
	Key.addListener(myKO);
	for (var i in infostruc) {
		loader.clear();
		loader.gradient_mc.removeMovieClip();
		loader.attachMovie("default","art",1);
		loader._width = frontCDWidth;
		loader._height = frontCDHeight;
		this["_bmd" + i] = new BitmapData(loader._width, loader._height);
		this["_ref" + i] = new BitmapData(loader._width, loader._height);
		this["_bmd" + i].draw(loader);
		var mc:MovieClip = loader.createEmptyMovieClip("gradient_mc", loader.getNextHighestDepth());
		matrix = new Matrix();
		matrix.createGradientBox(loader._width,loader._height,reflectionRotation / 180 * Math.PI,0,0);
		mc.beginGradientFill(reflectionFillType,reflectionColors,reflectionAlphas,reflectionRatios,matrix,reflectionSpreadMethod,reflectionInterpolationMethod,reflectionFocalPointRatio);
		mc.moveTo(0,0);
		mc.lineTo(0,loader._height);
		mc.lineTo(loader._width,loader._height);
		mc.lineTo(loader._width,0);
		mc.lineTo(0,0);
		mc.endFill();
		loader.art._alpha = reflectionAlpha;
		loader.beginFill(reflectionBackgroundColour);
		loader.moveTo(0,0);
		loader.lineTo(0,loader._height);
		loader.lineTo(loader._width,loader._height);
		loader.lineTo(loader._width,0);
		loader.lineTo(0,0);
		loader.endFill();
		this["_ref" + i].draw(loader);
	}
	for (var i:Number = count = 0; count < Stage.width - (centerDistance * 2); count += shelveCDSpacing, i++) {
		var cArt:MovieClip = this.createEmptyMovieClip("art" + this.getNextHighestDepth(), this.getNextHighestDepth());
		var rArt:MovieClip = this.createEmptyMovieClip("reflection" + (this.getNextHighestDepth() - 1), this.getNextHighestDepth());
		rArt.id = cArt.id = rArt.cid = cArt.cid = Number(i) + 1;
		cArt.DistortImage(this["_bmd" + cArt.id]);
		controlTheObject(cArt);
		rArt.DistortImage(this["_ref" + cArt.id]);
		controlTheObject(rArt);
		var tmpFilter:BlurFilter = new BlurFilter(reflectionBlurX, reflectionBlurY, reflectionQuality);
		rArt.filterArray = [];
		rArt.filterArray.push(tmpFilter);
		rArt.filters = rArt.filterArray;
	}
	myMO.onMouseWheel = function(delta:Number):Void  {
		if (delta > 0) {
			next();
		} else if (delta <= 0) {
			previous();
		}
	};
	myKO.onKeyDown = function():Void  {
		if (Selection.getFocus() != "_level0.goto") {
			if (Key.isDown(Key.RIGHT)) {
				next();
			} else if (Key.isDown(Key.LEFT)) {
				previous();
			}
		}
	};
	scrollBar.scroller.onPress = function():Void  {
		dist = this._parent._xmouse - this._x;
		this.onMouseMove = function():Void  {
			tmp = 1 + Math.ceil(((this._parent._xmouse - dist) - scrollBarStart) / (scrollBar._width - scrollBarStop) * (infostruc.length - 1));
			if (tmp > infostruc.length) {
				tmp = infostruc.length;
			}
			if (tmp < 1) {
				tmp = 1;
			}
			current = tmp;
			updateInfo();
		};
	};
	scrollBar.scroller.onRelease = scrollBar.scroller.onReleaseOutside = function ():Void {
		stopDrag();
		delete this.onMouseMove;
	};
	scrollBar.left.onPress = function():Void  {
		previous();
		shifter = setInterval(previous, scrollerDelay);
	};
	scrollBar.right.onPress = function():Void  {
		next();
		shifter = setInterval(next, scrollerDelay);
	};
	scrollBar.onMouseUp = function():Void  {
		clearInterval(shifter);
	};
	scrollBar.onMouseDown = function():Void  {
		if (this.hitTest(_xmouse, _ymouse, true) && !this.left.hitTest(_xmouse, _ymouse, true) && !this.right.hitTest(_xmouse, _ymouse, true)) {
			if (this._xmouse < this.scroller._x) {
				previous();
				shifter = setInterval(previous, clickDelay);
			}
			if (this._xmouse > this.scroller._x + this.scroller._width) {
				next();
				shifter = setInterval(next, clickDelay);
			}
		}
	};
	goto.onChanged = function():Void  {
		if (!isNaN(Number(this.text) + 1)) {
			this.text = Math.round(Number(this.text));
			if (this.text > infostruc.length) {
				this.text = infostruc.length;
			}
			if (this.text < 1) {
				this.text = 1;
			}
			current = this.text;
		} else {
			this.text = current;
		}
		updateInfo();
	};
	distance = Number(i);
	mask.removeMovieClip();
	loader.removeMovieClip();
	scrollBar.swapDepths(1101);
	loadNext();
	updateInfo();
}
function concat(m1, m2):Object {
	var mat:Object = {};
	mat.a = m1.c * m2.b;
	mat.b = m1.d * m2.b;
	mat.c = m1.a * m2.c;
	mat.d = m1.b * m2.c;
	mat.tx = m1.a * m2.tx + m1.c * m2.ty + m1.tx;
	mat.ty = m1.b * m2.tx + m1.d * m2.ty + m1.ty;
	return mat;
}
function updateInfo():Void {
	goto.text = current;
	img_info.author = infostruc[current - 1].auth;
	img_info.album = infostruc[current - 1].album;

	//Version 2 Addition
	img_info.artistLink.enabled = true;
	if (infostruc[current - 1].authLink == undefined) {
		img_info.authLink.enabled = false;
	} else {
		if (infostruc[current - 1].authLink == "undefined") {
			img_info.authLink.enabled = false;
		} else {
			img_info.artistLink.onPress = function() {
				getURL(infostruc[current - 1].authLink, "_blank");
			};
		}
	}
	img_info.albumLink.enabled = true;
	if (infostruc[current - 1].albumLink == undefined) {
		img_info.albumLink.enabled = false;
	} else {
		if (infostruc[current - 1].albumLink == "undefined") {
			img_info.albumLink.enabled = false;
		} else {
			img_info.albumLink.onPress = function() {
				getURL(infostruc[current - 1].albumLink, "_blank");
			};
		}
	}
	// 
	scrollBar.scroller._x = scrollBarStart + ((current - 1) / (infostruc.length - 1) * (scrollBar._width - scrollBarStop));
}
function validateOk(target:MovieClip):Boolean {
	return Math.abs(Math.min(Math.max((target._x - target.x) / albumEase, -maxSlide), maxSlide)) == maxSlide;
}
function controlTheObject(mc):Void {
	if (mc._name.indexOf("reflection") == -1) {
		mc.onPress = function():Void  {
			if (getTimer() - this.pressTime <= doubleClickRegister && this.pressTime) {
			}
			this.pressTime = getTimer();
			current = this.cid + 1;
			updateInfo();
		};
	}
	mc.onEnterFrame = function():Void  {
		if (Math.abs(this._x - this.x) > 1) {
			if (this._name.indexOf("reflection") == -1) {
				this._y = centerY;
				if (this._x >= centerX + centerDistance) {
					this.swapDepths(Stage.width - this._x);
					this.setSides(-(shelveCDWidth / 2),-(shelveCDHeight / 2) + ((Math.sin(angle * Math.PI / 180) * frontCDWidth)),-(shelveCDWidth / 2) + shelveCDWidth,-(shelveCDHeight / 2),-(shelveCDWidth / 2) + shelveCDWidth,shelveCDHeight / 2,-(shelveCDWidth / 2),(shelveCDHeight / 2) - ((Math.sin(angle * Math.PI / 180) * frontCDWidth)));
				} else if (this._x <= centerX - centerDistance) {
					this.swapDepths(this._x);
					this.setSides(-(shelveCDWidth / 2),-(shelveCDHeight / 2),-(shelveCDWidth / 2) + shelveCDWidth,-(shelveCDHeight / 2) + (Math.sin(angle * Math.PI / 180) * frontCDWidth),-(shelveCDWidth / 2) + shelveCDWidth,(shelveCDHeight / 2) - (Math.sin(angle * Math.PI / 180) * frontCDWidth),-(shelveCDWidth / 2),shelveCDHeight / 2);
				} else if (this._x > centerX - centerDistance && Math.floor(this._x) < centerX && !validateOk(this) && angle - ((this._x - (centerX - centerDistance)) / centerDistance * angle) > autoJump) {
					this.swapDepths(1002);
					var sum:Number = shelveCDWidth + ((this._x - (centerX - centerDistance)) / centerDistance * (frontCDWidth - shelveCDWidth));
					var sum2:Number = angle - ((this._x - (centerX - centerDistance)) / centerDistance * angle);
					var sum3:Number = shelveCDHeight + ((this._x - (centerX - centerDistance)) / centerDistance * (frontCDHeight - shelveCDHeight));
					this.setSides(-(sum / 2),-(sum3 / 2),-(sum / 2) + sum,-(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2) + sum,(sum3 / 2) - ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2),sum3 / 2);
				} else if (this._x < centerX + centerDistance && Math.ceil(this._x) > centerX && !validateOk(this) && angle - (((centerX + centerDistance) - this._x) / centerDistance * angle) > autoJump) {
					this.swapDepths(1003);
					var sum:Number = shelveCDWidth + (((centerX + centerDistance) - this._x) / centerDistance * (frontCDWidth - shelveCDWidth));
					var sum2:Number = angle - (((centerX + centerDistance) - this._x) / centerDistance * angle);
					var sum3:Number = shelveCDHeight + (((centerX + centerDistance) - this._x) / centerDistance * (frontCDHeight - shelveCDHeight));
					this.setSides(-(sum / 2),-(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2) + sum,-(sum3 / 2),-(sum / 2) + sum,sum3 / 2,-(sum / 2),(sum3 / 2) - ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)));
				} else if (!validateOk(this)) {
					this.swapDepths(1004);
					this.setSides(-(frontCDWidth / 2),-(frontCDHeight / 2),-(frontCDWidth / 2) + frontCDWidth,-(frontCDHeight / 2),-(frontCDWidth / 2) + frontCDWidth,frontCDHeight / 2,-(frontCDWidth / 2),frontCDHeight / 2);
				}
			} else {
				this._yscale = -100;
				if (this._x >= centerX + centerDistance) {
					this._y = centerY + shelveCDHeight + reflectionSpace;
					this.swapDepths((Stage.width - this._x) - 333);
					this.setSides(-(shelveCDWidth / 2),-(shelveCDHeight / 2) + (Math.sin(angle * Math.PI / 180) * frontCDWidth),-(shelveCDWidth / 2) + shelveCDWidth,-(shelveCDHeight / 2),-(shelveCDWidth / 2) + shelveCDWidth,shelveCDHeight / 2,-(shelveCDWidth / 2),(shelveCDHeight / 2) + ((Math.sin(angle * Math.PI / 180) * frontCDWidth)));
				} else if (this._x <= centerX - centerDistance) {
					this._y = centerY + shelveCDHeight + reflectionSpace;
					this.swapDepths(this._x - 333);
					this.setSides(-(shelveCDWidth / 2),-(shelveCDHeight / 2),-(shelveCDWidth / 2) + shelveCDWidth,-(shelveCDHeight / 2) + ((Math.sin(angle * Math.PI / 180) * frontCDWidth)),-(shelveCDWidth / 2) + shelveCDWidth,(shelveCDHeight / 2) + (Math.sin(angle * Math.PI / 180) * frontCDWidth),-(shelveCDWidth / 2),shelveCDHeight / 2);
				} else if (this._x > centerX - centerDistance && this._x < centerX && !validateOk(this)) {
					this.swapDepths(999);
					var sum:Number = shelveCDWidth + ((this._x - (centerX - centerDistance)) / centerDistance * (frontCDWidth - shelveCDWidth));
					var sum2:Number = angle - ((this._x - (centerX - centerDistance)) / centerDistance * angle);
					var sum3:Number = shelveCDHeight + ((this._x - (centerX - centerDistance)) / centerDistance * (frontCDHeight - shelveCDHeight));
					this._y = centerY + sum3 + reflectionSpace;
					this.setSides(-(sum / 2),-(sum3 / 2),-(sum / 2) + sum,-(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2) + sum,(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2),sum3 / 2);
				} else if (this._x < centerX + centerDistance && this._x > centerX && !validateOk(this)) {
					this.swapDepths(998);
					var sum:Number = shelveCDWidth + (((centerX + centerDistance) - this._x) / centerDistance * (frontCDWidth - shelveCDWidth));
					var sum2:Number = angle - (((centerX + centerDistance) - this._x) / centerDistance * angle);
					var sum3:Number = shelveCDHeight + (((centerX + centerDistance) - this._x) / centerDistance * (frontCDHeight - shelveCDHeight));
					this.setSides(-(sum / 2),-(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)),-(sum / 2) + sum,-(sum3 / 2),-(sum / 2) + sum,sum3 / 2,-(sum / 2),(sum3 / 2) + ((Math.sin(sum2 * Math.PI / 180) * frontCDWidth)));
					this._y = centerY + sum3 + reflectionSpace;
				} else if (!validateOk(this)) {
					this.swapDepths(995);
					this._y = centerY + frontCDHeight + reflectionSpace;
					this.setSides(-(frontCDWidth / 2),-(frontCDHeight / 2),-(frontCDWidth / 2) + frontCDWidth,-(frontCDHeight / 2),-(frontCDWidth / 2) + frontCDWidth,frontCDHeight / 2,-(frontCDWidth / 2),frontCDHeight / 2);
				}
			}
		}
		if (infostruc[this.cid].loaded && !this.loadedImage) {
			this.DistortImage(this._name.indexOf("reflection") > -1 ? this._parent["_ref" + this.cid] : this._parent["_bmd" + this.cid]);
			this.loadedImage = true;
		}
		if (this._x < deleteMinDistance && this._parent["_ref" + (this.cid + distance)]) {
			this.cid += distance;
			this._x = deleteMaxDistance;
			controlTheObject(this);
			this.loadedImage = infostruc[this.cid].loaded;
			this.DistortImage(this._name.indexOf("reflection") > -1 ? this._parent["_ref" + this.cid] : this._parent["_bmd" + this.cid]);
		}
		if (this._x > deleteMaxDistance && this._parent["_ref" + (this.cid - distance)]) {
			this.cid -= distance;
			this._x = deleteMinDistance;
			controlTheObject(this);
			this.loadedImage = infostruc[this.cid].loaded;
			this.DistortImage(this._name.indexOf("reflection") > -1 ? this._parent["_ref" + this.cid] : this._parent["_bmd" + this.cid]);
		}
		if (this.cid + 1 > current) {
			this.x = (centerX + ((this.cid + 1 - current) * shelveCDSpacing)) + centerDistance;
		} else if (this.cid + 1 < current) {
			this.x = (centerX + ((this.cid + 1 - current) * shelveCDSpacing)) - centerDistance;
		} else {
			this.x = centerX + ((this.cid + 1 - current) * shelveCDSpacing);
		}
		this._x -= Math.min(Math.max((this._x - this.x) / albumEase, -maxSlide), maxSlide);
		if (this._x < fadeDist) {
			this._alpha = (this._x / fadeDist * 100);
		} else if (this._x > fadePoint - fadeDist) {
			this._alpha = ((fadePoint - this._x) / fadeDist * 100);
		} else {
			this._alpha = 100;
		}
		this.setTransform(this.px1,this.py1,this.px2,this.py2,this.px3,this.py3,this.px4,this.py4);
	};
}
function next():Void {
	if (current < infostruc.length) {
		current += 1;
	}
	updateInfo();
}
function previous():Void {
	if (current > 1) {
		current -= 1;
	}
	updateInfo();
}
function displayAlternArt(art, width:Number, height:Number):Void {
	artDisplay.attachBitmap(art,1);
	artDisplay._width = width;
	artDisplay._height = height;
}
function loadNext():Void {
	if (!loadedAll) {
		var num:Number = current - 1;
		if (infostruc[current - 1].loaded) {
			var num:Number = current - Math.floor(distance / 2) - 1 >= 0 ? current - Math.floor(distance / 2) - 1 : 0;
			while (infostruc[num].loaded && num < infostruc.length) {
				num++;
			}
			if (num >= infostruc.length) {
				var num:Number = current - 1;
				while (infostruc[num].loaded && num > 0) {
					num--;
				}
				if (num <= 0) {
					loadedAll = true;
				}
			}
		}
		var newLoad:MovieClip = this.createEmptyMovieClip("artLoad" + num, this.getNextHighestDepth());
		newLoad.createEmptyMovieClip("art",newLoad.getNextHighestDepth());
		newLoad._alpha = 0;
		var mc:Object = {};
		mc.number = num;
		var artLoader:MovieClipLoader = new MovieClipLoader();
		artLoader.addListener(mc);
		artLoader.loadClip("./" + infostruc[num].art,newLoad.art);
		mc.onLoadError = function() {
			infostruc[this.number].loaded = true;
			loadNext();
		};
		mc.onLoadInit = function(target:MovieClip) {
			target._parent._width = frontCDWidth;
			target._parent._height = frontCDHeight;
			root["_bmd" + this.number] = new BitmapData(target._width, target._height);
			root["_ref" + this.number] = new BitmapData(target._width, target._height);
			root["_bmd" + this.number].draw(target);
			var mc:MovieClip = target._parent.createEmptyMovieClip("gradient_mc", target._parent.getNextHighestDepth());
			matrix = new Matrix();
			matrix.createGradientBox(target._width,target._height,reflectionRotation / 180 * Math.PI,0,0);
			mc.beginGradientFill(reflectionFillType,reflectionColors,reflectionAlphas,reflectionRatios,matrix,reflectionSpreadMethod,reflectionInterpolationMethod,reflectionFocalPointRatio);
			mc.moveTo(0,0);
			mc.lineTo(0,target._height);
			mc.lineTo(target._width,target._height);
			mc.lineTo(target._width,0);
			mc.lineTo(0,0);
			mc.endFill();
			target._alpha = 50;
			target._parent.beginFill(reflectionBackgroundColour);
			target._parent.moveTo(0,0);
			target._parent.lineTo(0,target._height);
			target._parent.lineTo(target._width,target._height);
			target._parent.lineTo(target._width,0);
			target._parent.lineTo(0,0);
			target._parent.endFill();
			root["_ref" + this.number].draw(target._parent);
			infostruc[this.number].loaded = true;
			target._parent.removeMovieClip();
			updateInfo();
			loadNext();
		};
	}
}
xmlData.onLoad = function(success:Boolean):Void  {
	if (success) {
		for (var i:Number = -1; this.childNodes[0].childNodes[++i]; ) {
			var cNode:XMLNode = this.childNodes[0].childNodes[i].childNodes;
			var val2:String = cNode[1].childNodes[0].nodeValue ? unescape(cNode[1].childNodes[0].nodeValue) : unknownArtist;
			var val3:String = cNode[2].childNodes[0].nodeValue ? unescape(cNode[2].childNodes[0].nodeValue) : unknownAlbum;
			var val4:String = cNode[3].childNodes[0].nodeValue ? unescape(cNode[3].childNodes[0].nodeValue) : noLink;
			var val5:String = cNode[4].childNodes[0].nodeValue ? unescape(cNode[4].childNodes[0].nodeValue) : noLink;
			infostruc.push({art:cNode[0].childNodes[0].nodeValue, info:val1, auth:val2, album:val3, authLink:val4, albumLink:val5, loaded:false});
		}
		loadStat = "";
		init();
	} else {
		loadStat = "Unable to load XML Data";
	}
};
xmlData.ignoreWhite = true;
//xmlData.load("./albuminfo.xml");
xmlData.load(albumInfoXML);

this.createEmptyMovieClip("loader",this.getNextHighestDepth());
loader._visible = false;
mask._alpha = 0;
scrollBar.scroller._y = 0;
img_info.swapDepths(2000);