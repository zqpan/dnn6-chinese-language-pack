﻿jQuery(document).ready(function ($) {

  //On Hover Over
  function megaHoverOver() {
    $(this).addClass('mmItemHover').find(".megaborder").stop().show(); //Find sub and fade it in
    (function ($) {
      //Function to calculate max width of menu
      jQuery.fn.calcMaxDimensions = function () {
        maxWidth = 0;
		maxHeight = 0;
		numColumns = 0;
		maxColumns = 3; // set to desired number of colummns
        //Calculate widest category
        $(this).find("li.category").each(function () { //for each ul...
			numColumns++;
			maxWidth = ($(this).width() > maxWidth) ? $(this).width() : maxWidth; //Check current category width against largest width
        });
		maxWidth = (numColumns > maxColumns) ? (maxWidth * maxColumns) : (maxWidth * numColumns);
		//Calculate tallest category
		$(this).find("li.category").each(function () { //for each ul...
			maxHeight = ($(this).height() > maxHeight) ? $(this).height() : maxHeight; //Check current category height against largest height
        });
      };
    })(jQuery);

	$(this).calcMaxDimensions();  //Call function to calculate max width of menu
	$(this).find(".megaborder").css({ 'width': maxWidth + 20 }); //Set Width
	$(this).find("li.category").each(function() {
		var thisPosition = $(this).index() + 1; // node position of category
		if (thisPosition % 3 == 0) {
			$(this).addClass("mmRightColumn");
		}
	}).css({ 'height': maxHeight });

  }

  //On Hover Out
  function megaHoverOut() {
    $(this).removeClass('mmItemHover').find(".megaborder").stop().fadeOut('fast', function () { //Fade to 0 opactiy
      $(this).hide();  //after fading, hide it
    });
  }

  //Set custom configurations
  var config = {
    sensitivity: 2, // number = sensitivity threshold (must be 1 or higher)
    interval: 100, // number = milliseconds for onMouseOver polling interval
    over: megaHoverOver, // function = onMouseOver callback (REQUIRED)
    timeout: 500, // number = milliseconds delay before onMouseOut
    out: megaHoverOut // function = onMouseOut callback (REQUIRED)
  };

  //$("ul.dnnmega li .megaborder").css({ 'opacity': '0' }); //Fade sub nav to 0 opacity on default
$("ul.dnnmega li.mmHasChild").hoverIntent(config); //Trigger Hover intent with custom configurations
  //Code goes here
});