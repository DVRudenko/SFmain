function insert(pobjSelect, psText, psValue){
 var lobjOption = document.createElement("Option"); lobjOption.text = psText;  lobjOption.value = psValue;  pobjSelect.options.add(lobjOption);
}
var winLoaded = window.onload;
window.onload = function(){   if(winLoaded){
  winLoaded();
 }
 var e = document.getElementById("calYearPicker");
 if(e != null){
  for(i = e.length - 1; i>=0; i--){
   e.remove(i);
  }
  var d = new Date();    var startYear = d.getFullYear() + 6;
  for(var i = 1920; i<startYear; i++){    insert(e, i, i);   }  }
}

