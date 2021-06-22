//Function is used to get splash status bar when server side call is going on
function startSplash() {
    document.getElementById('splashDiv').style.display='table-cell';
    $('.lightbox').fadeIn(300);
}

//Function will make the splash status to be stopped.
function endSplash() {
    document.getElementById('splashDiv').style.display='none';
    $('.lightbox').fadeOut(300); 
}