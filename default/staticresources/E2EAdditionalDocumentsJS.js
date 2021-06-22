$j = jQuery.noConflict();

$j(document).ready(function () {
    var clientHeight = document.documentElement.clientHeight - 5;
    if (clientHeight > 390) clientHeight =  390;

    $j('.mainform').height(clientHeight);
    $j(".mainform").mCustomScrollbar({
        theme:"dark"
    });
});


