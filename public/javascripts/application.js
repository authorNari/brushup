// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Brushup ={
  clearInputValue : function(input_text) {
    input_text.value = "";
    input_text.style.color = "black";
  }
};

/* shows and hides ajax indicator(by redmine) */
Ajax.Responders.register({
    onCreate: function(){
        if ($('ajax-indicator') && Ajax.activeRequestCount > 0) {
            Element.show('ajax-indicator');
        }
    },
    onComplete: function(){
        if ($('ajax-indicator') && Ajax.activeRequestCount == 0) {
            Element.hide('ajax-indicator');
        }
    }
});
