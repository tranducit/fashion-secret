
var rwmPodNavImgSrc = "rwmPodNav6_150px.gif";

var rwmPodNavRefs = new Array();

function rwmScrollerDiv (divid, scrollspeed)
{
	this.divid = divid;
	this.div = document.getElementById(divid);
	this.style = this.div.style;

	this.scrollspeed = scrollspeed;

	this.DoScroll = function (pix)
	{
		this.div.scrollTop += pix * this.scrollspeed;
	}

	this.ScrollToTop = function ()
	{
		this.div.scrollTop = 0;
	}

	this.ScrollToBottom = function ()
	{
		// HACK: nasty way of doing it >:o|
		this.div.scrollTop = 65000;
	}

	this.LoremIpsum = function (num)
	{
		this.div.innerHTML = "";
		for (i = 0; i < num; i++)
		{
			this.div.innerHTML += "<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>";
		}
	}
}


function rwmPodNav (divid, scrollerobject, imgsrc)
{
	this.divid = divid;
	this.div = document.getElementById(divid);
	this.style = this.div.style;

	this.scrollerobject = scrollerobject;

	this.w = parseInt(this.style.width);
	this.h = parseInt(this.style.height);
	this.w2 = Math.floor(this.w / 2);
	this.h2 = Math.floor(this.h / 2);

	this.lastAng = 0;
	this.ignoreLastAngle = true;

	this.divimgid = this.divid + "img";
	this.div.innerHTML = "<img id='" + this.divimgid + "' src='" + (imgsrc ? imgsrc : rwmPodNavImgSrc) + "' width='100%' height='100%' />";
	this.divimg = document.getElementById(this.divimgid);

	this.DeterminePosition = function ()
	{
		var pos = rwmElementPosition(this.divimg);
		this.offsetX = pos.x;
		this.offsetY = pos.y;
	}

	this.DeterminePosition();

	rwmPodNavRefs[this.divimgid] = this;


	this.ClickedUp = function ()
	{
		this.scrollerobject.ScrollToTop();
	}

	this.ClickedDown = function ()
	{
		this.scrollerobject.ScrollToBottom();
	}

	this.ClickedLeft = function ()
	{
		history.back();
	}

	this.ClickedRight = function ()
	{
		history.forward();
	}

	this.MouseOver = function ()
	{
	}

	this.MouseOut = function ()
	{
		this.ignoreLastAngle = true;
	}

	this.MouseMove = function (x, y)
	{

		// center the coords
		x = x - this.offsetX - this.w2;
		y = y - this.offsetY - this.h2;

		// Check range...
		// Chis is a crude way of determining if our position has changed due to a window resize.
		// We really don't want to have to determine our position on every mouse over!
		if (Math.abs(x) > this.w2 || Math.abs(y) > this.h2) this.DeterminePosition();

		// DEBUG: window.status = "" + x + " , " + y;

		// flip so that y is positive and atan creates clockwise rotation
		y = -y;

		// determine the angle (north = 0 radians. Clockwise = positive)
		if (y == 0)
		{
			ang = (x <= 0) ? Math.PI / -2 : Math.PI / 2;
		}
		else
		{
			ang = Math.atan(x / y);
		}
		if (x >= 0 && y < 0) ang = ang + Math.PI
		if (x < 0 && y < 0) ang = ang - Math.PI;

		if (this.ignoreLastAngle)
		{
			angdiff = 0;
			this.ignoreLastAngle = false;
		}
		else
		{
			angdiff = ang - this.lastAng;
			if (Math.abs(angdiff) > Math.PI) angdiff = 0;
		}
		this.lastAng = ang;

		// multiplying by 60 seems to give a sensible pixel scroll rate
		pixscroll = angdiff * 60;
		if (angdiff > 0 && angdiff < 1) angdiff = 1;

		if (this.scrollerobject) this.scrollerobject.DoScroll(pixscroll);
	}

	this.MouseWheel = function (wheelDelta)
	{
		pixscroll = (wheelDelta < 0) ? 100 : -100;
		if (this.scrollerobject) this.scrollerobject.DoScroll(pixscroll);
	}

	this.MouseClick = function (x, y)
	{
		// center the coords
		x = x - this.offsetX - this.w2;
		y = y - this.offsetY - this.h2;
		// determine the quadrant, split on diagonals
		var quadrant = 0; // 0 = dunno, 1 = top, 2 = right, 3 = bottom, 4 = left
		if (Math.abs(x) >= Math.abs(y))
		{
			// left or right
			quadrant = (x >= 0) ? 2 : 4;
		}
		else
		{
			// top or bottom
			quadrant = (y >= 0) ? 3 : 1;
		}
		if (quadrant == 1) this.ClickedUp();
		if (quadrant == 2) this.ClickedRight();
		if (quadrant == 3) this.ClickedDown();
		if (quadrant == 4) this.ClickedLeft();
	}

	// Note:
	// Despite being set as object methods, these event handlers still need to reference the actual object
	// using the event element's id looked up within an array. There is no "this" context for these events.

	this.divimg.onmousemove = function (evt)
	{
		e = new rwmEvent(evt);
		if (e.event && e.element) {
			objref = rwmPodNavRefs[e.element.id];
			if (objref) objref.MouseMove(e.x, e.y);
		}
	}

	this.divimg.onmousewheel = function (evt)
	{
		e = new rwmEvent(evt);
		if (e.event && e.element) {
			objref = rwmPodNavRefs[e.element.id];
			if (objref) objref.MouseWheel(e.event.wheelDelta);
		}
	}

	this.divimg.onclick = function (evt)
	{
		e = new rwmEvent(evt);
		if (e.event && e.element) {
			objref = rwmPodNavRefs[e.element.id];
			if (objref) objref.MouseClick(e.x, e.y);
		}
	}

	this.divimg.onmouseover = function (evt)
	{
		e = new rwmEvent(evt);
		if (e.event && e.element) {
			objref = rwmPodNavRefs[e.element.id];
			if (objref) objref.MouseOver();
		}
	}

	this.divimg.onmouseout = function (evt)
	{
		e = new rwmEvent(evt);
		if (e.event && e.element) {
			objref = rwmPodNavRefs[e.element.id];
			if (objref) objref.MouseOut();
		}
	}
}
