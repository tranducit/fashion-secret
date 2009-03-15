/*
 * rwmCoverFlow by Raith
 *
 * v2.00 02/03/2009
 * v1.00 24/03/2008
 *
 * This is the second release of my CoverFlow script.
 *
 * Upgraded to use v2.0 js reflection so this is finally compatible with Google Chrome.
 * A number of people have asked that this handle non-square images which is the other change
 * I'm making in v2.
 *
 * It's not really release standard as there are loads of rough edges and my code isn't very nice.
 * But it's really just for myself you know? I've seen so much good code released by talented people
 * only for their blog to be filled by lameasses asking dumb questions that it's really put me off the
 * idea of doing it myself. This code is clean and o-o enough to make sense to a smart scripter. If
 * that's you then I am happy for you to take this code. I only ask that you feed back any improvements
 * you make to me so that I can benefit from your experience in return for this starting point that I
 * offer you.
 *
 * For a perfect partnership, pair this with my rwmPodNav module which allows you to scroll iPod style
 * by circling your mouse over a suitable image.
 *
 * Please note that this script contains a slightly hacked version of the marvellous Reflection.js v2.0
 * script. I had to hack it so that the widths were not fixed as my CoverFlow applies widths to the
 * containing div; with the image and reflection being set to 100%. I apologise for the nasty hacks and
 * for renaming your objects, which I have done to avoid clashing with the pure form of your code.
 * Kudos! http://cow.neondragon.net/stuff/reflection/
 *
 * Other than the reflection code, the rest is entirely my own.
 *
 */

/*
 * TODO: known issues which may be fixed one day...
 *
 * 01. The grey border was an afterthought and has 2 problems. One is that it is added to the outerdiv
 *     inside which are 2 elements which have width=100%. This means that the outerdiv actually ends up
 *     bigger than the width I set. So the absolute positioning "left" calcualtion has a hack to make up
 *     for this. If the left border stays in then I will accomodate it more cleanly.
 *
 * 02. The second grey border issue is that it is not reflected nicely. It has constant opacity all the
 *     way down the side of the image and the reflection. Not much I can do about that other than give the
 *     reflection it's own lighter border.
 *
 * 03. The central cover occupies more space than the swivelled ones. There is a hack in the "left"
 *     positioning to jump the non-central ones out a bit further. I should use a linear function to make
 *     this smoother. As it is there is a slight jump as the central cover flips in or out.
 *
 * 04. The covers do not really flip into the distance. They just compress laterally. The slant effect is
 *     merely a triangular patch applied on top of the image using border styling. This relies on the the
 *     browser supporting "transparent" borders. It will definitely break somwhere.
 *
 * 05. Applying the reflections was a mite dodgy. I tried to do it in code but something always broke in
 *     one browser or another. I think it's coz my images aren't displayed early enough for the reflection
 *     code to be able to do it's job. The canvas variation was more delicate than the IE one. After much
 *     mucking about I reinstated the class="reflect" solution so that it runs after my code has already
 *     adapted the dom. It seems to work best that way but I'd rather be more in control. I did toy with the
 *     idea of adding the reflections BEFORE I adapted the dom but I didn't want to refactor that much of my
 *     code at this stage so it's something for the future.
 *
 */

function CoverFlow (div, coversizeX, coversizeY, flowwidth, edgecolour, CoverClickCallback)
{

	// Tweaks -----------------------------------
	
 	this.scrollSpeed = 0.20;
	this.scrollMaxJump = 0.25;

	// ------------------------------------------

	this.div = div; //document.getElementById(div);
	this.coversizeX = coversizeX;
	this.coversizeY = coversizeY;
	this.halfsize = coversizeX / 2;
	this.flowwidth = flowwidth;
	this.halfwidth = flowwidth / 2;
	this.edgecolour = edgecolour;
	this.CoverClickCallback = CoverClickCallback;

	this.div.style.position = "relative";
	this.div.style.width = this.flowwidth + "px";
	this.div.style.height = 1.5 * this.coversizeY + "px";
	this.div.style.overflow = "hidden";

	this.targetPos = 0;
	this.scrollPos = 0;

	this.Covers = [];
	while (this.div.childNodes.length > 0)
	{
		child = this.div.firstChild;
		if (child.nodeName == "IMG")
		{
			this.Covers.push(new CoverFlowItem(this, this.Covers.length, child.src));
		}
		this.div.removeChild(child);
	}
	for (i in this.Covers)
	{
		this.div.appendChild(this.Covers[i].outerdiv);
	}

	this.needReflections = false;
	this.Update = function ()
	{
		offset = this.targetPos - this.scrollPos;
		scrollamount = offset * this.scrollSpeed;
		if (Math.abs(scrollamount) > this.scrollMaxJump)
		{
			offsetabs = Math.abs(offset);
			if (offsetabs > 3)
			{
				scrollamount = offset / 6;
			}
			else
			{
				scrollamount = this.scrollMaxJump * (scrollamount > 0 ? 1 : -1);
			}
		}
		this.scrollPos += scrollamount;

		for (i = 0; i < this.Covers.length; i++)
		{
			this.Covers[i].Update(this.halfwidth, this.halfwidth, i - this.scrollPos);
		}

		if (this.needReflections)
		{
			for (i = 0; i < this.Covers.length; i++)
			{
				CoverFlowReflection.add(this.Covers[i].coverimg);
			}
			this.needReflections = false;
		}
	};

	this.Goto = function (newpos)
	{
		newpos = Math.max(newpos, 0);
		newpos = Math.min(newpos, this.Covers.length - 1);
		this.targetPos = newpos;
	};

	this.Flip = function (flipamount)
	{
		this.Goto (this.targetPos + flipamount);
	};

	this.GotoFirst = function ()
	{
		this.Goto(0);
	};

	this.GotoLast = function ()
	{
		this.Goto(this.Covers.length - 1);
	};

	this.ClickedCover = function (Cover)
	{
		this.Goto(Cover.CoverIndex);
		if (CoverClickCallback)
		{
			CoverClickCallback(Cover);
		}
	};

	/*
	 * These scroll methods are to make this a compatible 'scroller object' for my rwmPodNav module.
	 * The two make a perfect partnership!!
	 */

	var scrollerinput = 0;
	this.DoScroll = function (pix)
	{
		scrollerinput += pix;
		jumpamount = Math.floor(scrollerinput / 50);
		scrollerinput -= (jumpamount * 50);
		this.Flip(jumpamount);
	};

	this.ScrollToTop = function ()
	{
		this.GotoFirst();
	};

	this.ScrollToBottom = function ()
	{
		this.GotoLast();
	};

}

function CoverFlowItem (CoverFlowObj, CoverIndex, imgSrc)
{
	this.CoverFlow = CoverFlowObj;
	this.CoverIndex = CoverIndex;
	this.imgSrc = imgSrc;

	this.outerdiv = document.createElement("div");
	this.coverimg = document.createElement("img");
	this.edgesdiv = document.createElement("div");
	this.outerdiv.appendChild(this.coverimg);
	this.outerdiv.appendChild(this.edgesdiv);

	this.innerdiv = document.createElement("div");
	this.outerdiv.appendChild(this.innerdiv);

	this.coverimg.src = imgSrc;

	this.outerdiv.style.position = "absolute";
	this.outerdiv.style.width = this.CoverFlow.coversizeX + "px";
	this.outerdiv.style.borderLeftStyle = "solid";
	this.outerdiv.style.borderLeftColor = "#eee";
	this.outerdiv.style.borderRightStyle = "solid";
	this.outerdiv.style.borderRightColor = "#eee";
	this.coverimg.style.width = "100%";
	this.coverimg.className = "reflect";
	this.edgesdiv.style.position = "absolute";
	this.edgesdiv.style.top = "0px";
	this.edgesdiv.style.left = "0px";
	this.edgesdiv.style.borderTopStyle = "solid";
	this.edgesdiv.style.borderRightStyle = "solid";
	this.edgesdiv.style.borderBottomStyle = "none";
	this.edgesdiv.style.borderLeftStyle = "solid";
	this.edgesdiv.style.borderLeftWidth = "0px";
	this.edgesdiv.style.borderLeftColor = "transparent";
	this.edgesdiv.style.borderRightWidth = "0px";
	this.edgesdiv.style.borderRightColor = "transparent";
	this.edgesdiv.style.borderTopColor = this.CoverFlow.edgecolour;

	this.createClickHandler = function ()
	{
		var self = this;
		return function ()
		{
			self.CoverFlow.ClickedCover(self);
		};
	};

	this.coverimg.onclick = this.createClickHandler();

	this.Update = function (xorigin, range, xoffset)
	{
		xoffsetabs = Math.abs(xoffset);
		xoffsetsign = xoffset >= 0 ? 1 : -1;
		if (xoffsetabs < 1)
		{
			proportion = 0.3 + 0.7 * (1 - (xoffsetabs - Math.floor(xoffsetabs)));
		}
		else
		{
			proportion = 0.3;
		}

		scaledsize = Math.round(this.CoverFlow.coversizeX * proportion);
		if (scaledsize < 1) scaledsize = 1;
		if (scaledsize > this.CoverFlow.coversizeX) scaledsize = this.CoverFlow.coversizeX;
		bordersize = Math.round((this.CoverFlow.coversizeX - scaledsize) * 0.2);
		bordersizeedge = bordersize * 0.5;

		this.coverimg.style.height = this.CoverFlow.coversizeY + "px";
		this.edgesdiv.style.borderTopWidth = bordersize + "px";
		if (xoffsetsign == 1)
		{
			this.edgesdiv.style.borderLeftWidth = "0px";
			this.edgesdiv.style.borderRightWidth = scaledsize + "px";
			this.outerdiv.style.borderLeftWidth = "0px";
			this.outerdiv.style.borderRightWidth = bordersizeedge + "px";
		}
		else
		{
			this.edgesdiv.style.borderLeftWidth = scaledsize + "px";
			this.edgesdiv.style.borderRightWidth = "0px";
			this.outerdiv.style.borderLeftWidth = bordersizeedge + "px";
			this.outerdiv.style.borderRightWidth = "0px";
		}

		if (xoffsetabs > 0.4)
		{
			left = xorigin + (this.CoverFlow.coversizeX * xoffset * 0.4) + (xoffsetsign * this.CoverFlow.coversizeX * 0.3);
			if (xoffsetsign == -1) left -= bordersizeedge; // coz this is unofficially added to the outerdiv width
		}
		else
		{
			left = xorigin + (this.CoverFlow.coversizeX * xoffset);
		}
		left -= scaledsize * 0.5; // "centre" the current cover
		left = Math.round(left);
		
		this.outerdiv.style.left = left + "px";
		this.outerdiv.style.width = scaledsize + "px";
		this.outerdiv.style.zIndex = Math.round(1000 + 100 * proportion - xoffsetabs);

	};
}



/**
 * reflection.js v2.0
 * http://cow.neondragon.net/stuff/reflection/
 * Freely distributable under MIT-style license.
 */
 
/*
 * Horribly hacked by Raith on 23/03/2008, and then again on 02/03/2009
 *
 * Had to hack this so it would play nicely with my CoverFlow script.
 * I had to tinker with the dimension code so that the width can be set by the outer div, so replaced 'px' settings with '100%'.
 * Also changed the method of applying vertical-align to overcome a problem in some cases.
 *
 * I'm truly sorry to Cow for having to hack his code in this way. I have renamed the class to CoverFlowReflection so that it does
 * not clash with the real Reflection script if you are using that too. It is NOT an attempt by me to claim the code as my own!
 *
 * If you like the reflection then please do not use my hacked version! You really MUST download the original from http://cow.neondragon.net/stuff/reflection/
 *
 */

/* From prototype.js */
if (!document.myGetElementsByClassName) {
	document.myGetElementsByClassName = function(className) {
		var children = document.getElementsByTagName('*') || document.all;
		var elements = new Array();
	  
		for (var i = 0; i < children.length; i++) {
			var child = children[i];
			var classNames = child.className.split(' ');
			for (var j = 0; j < classNames.length; j++) {
				if (classNames[j] == className) {
					elements.push(child);
					break;
				}
			}
		}
		return elements;
	}
}

var CoverFlowReflection = {
	defaultHeight : 0.4,
	defaultOpacity: 0.2,
	
	add: function(image) {
		CoverFlowReflection.remove(image);
		
		options = { "height" : CoverFlowReflection.defaultHeight, "opacity" : CoverFlowReflection.defaultOpacity }
	
		try {
			var d = document.createElement('div');
			var p = image;
			
			var classes = p.className.split(' ');
			var newClasses = '';
			for (j=0;j<classes.length;j++) {
				if (classes[j] != "reflect") {
					if (newClasses) {
						newClasses += ' '
					}
					
					newClasses += classes[j];
				}
			}

			var reflectionHeight = Math.floor(p.height*options['height']);
			var divHeight = Math.floor(p.height*(1+options['height']));
			
			var reflectionWidth = p.width;
			
			if (document.all && !window.opera) {
				/* Fix hyperlinks */
                if(p.parentElement.tagName == 'A') {
	                var d = document.createElement('a');
	                d.href = p.parentElement.href;
                }  
                    
				/* Copy original image's classes & styles to div */
				d.className = newClasses;
				p.className = 'reflected';
				
				d.style.cssText = p.style.cssText;
				//p.style.cssText = 'vertical-align: bottom';
				p.style.verticalAlign = 'bottom';
			
				var reflection = document.createElement('img');
				reflection.src = p.src;
				//reflection.style.width = reflectionWidth+'px';
				reflection.style.width = '100%';
				reflection.style.display = 'block';
				reflection.style.height = p.height+"px";
				
				reflection.style.marginBottom = "-"+(p.height-reflectionHeight)+'px';
				reflection.style.filter = 'flipv progid:DXImageTransform.Microsoft.Alpha(opacity='+(options['opacity']*100)+', style=1, finishOpacity=0, startx=0, starty=0, finishx=0, finishy='+(options['height']*100)+')';
				
				//d.style.width = reflectionWidth+'px';
				d.style.width = '100%';
				d.style.height = divHeight+'px';
				p.parentNode.replaceChild(d, p);
				
				d.appendChild(p);
				d.appendChild(reflection);
			} else {
				var canvas = document.createElement('canvas');
				if (canvas.getContext) {
					/* Copy original image's classes & styles to div */
					d.className = newClasses;
					p.className = 'reflected';
					
					d.style.cssText = p.style.cssText;
					//p.style.cssText = 'vertical-align: bottom';
					p.style.verticalAlign = 'bottom';
			
					var context = canvas.getContext("2d");
				
					canvas.style.height = reflectionHeight+'px';
					//canvas.style.width = reflectionWidth+'px';
					canvas.style.width = '100%';
					canvas.height = reflectionHeight;
					canvas.width = reflectionWidth;
					
					//d.style.width = reflectionWidth+'px';
					d.style.width = '100%';
					d.style.height = divHeight+'px';
					p.parentNode.replaceChild(d, p);
					
					d.appendChild(p);
					d.appendChild(canvas);
					
					context.save();
					
					context.translate(0,image.height-1);
					context.scale(1,-1);
					
					context.drawImage(image, 0, 0, reflectionWidth, image.height);
	
					context.restore();
					
					context.globalCompositeOperation = "destination-out";
					var gradient = context.createLinearGradient(0, 0, 0, reflectionHeight);
					
					gradient.addColorStop(1, "rgba(255, 255, 255, 1.0)");
					gradient.addColorStop(0, "rgba(255, 255, 255, "+(1-options['opacity'])+")");
		
					context.fillStyle = gradient;
					context.rect(0, 0, reflectionWidth, reflectionHeight*2);
					context.fill();
				}
			}
		} catch (e) {
	    }
	},
	
	remove : function(image) {
		if (image.className == "reflected") {
			image.className = image.parentNode.className;
			image.parentNode.parentNode.replaceChild(image, image.parentNode);
		}
	}
}


function addCoverFlowReflections() {
	var rimages = document.myGetElementsByClassName('reflect');
	for (i=0;i<rimages.length;i++) {
		CoverFlowReflection.add(rimages[i]);
	}
}

var previousOnload = window.onload;
window.onload = function () { if(previousOnload) previousOnload(); addCoverFlowReflections(); }

