
var rwmDebug = false;



// Write out a script tag to load the specified file ONLY if the provided reference is undefined after evaluation.
function rwmIncludeScript ( ScriptFile , Reference )
{

	if (typeof(eval(Reference)) == "undefined")
	{
		document.write("<script language=\"javascript\" src=\"" + ScriptFile + "\"></script>");
	}

}


// Neutralise browser event argument handling. Send this the (e) parameter from an event handler.
function rwmEvent (evt)
{
	this.event = (evt) ? evt : ((window.event) ? event : null);
	if (this.event)
	{
		this.element = (this.event.target) ? this.event.target : this.event.srcElement;
		if (this.event.pageX || this.event.pageY)
		{
			this.x = this.event.pageX;
			this.y = this.event.pageY;
		}
		else if (this.event.clientX || this.event.clientY)
		{
			this.x = this.event.clientX + document.body.scrollLeft;
			this.y = this.event.clientY + document.body.scrollTop;
		}
	}
}


// Quick'n'dirty debugging. List an object's properties.
function rwmListProperties (obj, popup)
{
	var report = "";
	for (i in obj)
	{
		report += i + " = " + obj[i] + "\n";
	}
	if (popup)
	{
		var win = window.open("", "props");
		win.document.write(report.replace(/</g, "&lt;").replace(/\n/g, "<br>"));
	}
	return report;
}


function rwmElementPosition (element)
{
	/*
	 * Crudely determines location of an element.
	 * Needs further fudging for IE as values are not right yet!!
	 */
	var el = element;
	var x = el.offsetLeft;
	var y = el.offsetTop;
	// this loop builds up a cumulative offset (which might not be bang on!)
	while (el = el.offsetParent)
	{
		if (rwmDebug) alert("parent element " + el.tagName + " (" + el.id + ") at " + el.offsetLeft + " , " + el.offsetTop);
		x += el.offsetLeft;
		y += el.offsetTop;
	}
	if (rwmDebug) alert("cumulative offset = " + x + " , " + y);
	return {x: x, y: y};
}


