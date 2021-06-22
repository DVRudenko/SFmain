ymaps.ready(init);

var myMap;

function init() {
    myMap = new ymaps.Map('map', {
        center: [55.753994, 37.622093],
        zoom: 9,
        controls: ['routePanelControl']
    });
    initiateCreateRoute();
}

function createRoute(ad1, ad2){
    ad1 = transferSourceAddress(ad1);
    ad2 = transferTargetAddress(ad2);

    // Получение ссылки на панель маршрутизации.
    var control = myMap.controls.get('routePanelControl');

    control.routePanel.options.set({
        types: {  // Типы маршрутизации, которые будут доступны для выбора пользователям.
            "auto": true,
            "masstransit": true,
            "pedestrian": true,
            "taxi": true
        },
        allowSwitch: true
    });

    control.routePanel.state.set({
        from: ad1,
        to: ad2,
        type: "auto"
    });

    var multiRoutePromise = control.routePanel.getRouteAsync();
    multiRoutePromise.then(function(multiRoute) {
        // Подписка на событие обновления мультимаршрута.
        multiRoute.model.events.add('requestsuccess', function() {
            var activeRoute = multiRoute.getActiveRoute();
            if (activeRoute) {
                document.getElementById('track1').innerHTML = "Расстояние: " + activeRoute.properties.get("distance").text + "<br>" +
                                                              "Время: " + activeRoute.properties.get("duration").text
            }
        });
    }, function (err) {
         console.log(err);
    });
}

function transferSourceAddress(address){
    if(address == 'Свердловская область') {
        address = 'Екатеринбург';
    }
    else if (address == 'Ленинградская область') {
        address = 'Санкт-Петербург';
    }
    return address;
}

function transferTargetAddress(address){
    address = address.toUpperCase();
    var symbols = [' Г.','. Г '];

    var regex = new RegExp('^([0-9]){6}'); // remove index
    if((address.trim() != '') && regex.test(address)){
        address = address.slice(6, address.length);
    }
    for(var i = 0; i < symbols.length; i++){ // remove town
        if(address.includes(symbols[i])){
            address = address.replace(symbols[i],'');
        }
    }


    return address;
}

function createMultiRoute(ad1,ad2,ad3){
    var multiRoute = new ymaps.multiRouter.MultiRoute(
        { // Точки маршрута. Точки могут быть заданы как координатами, так и адресом.
            referencePoints: [
                ad1,
                ad2,
                ad3
            ]
        },
        { // Автоматически устанавливать границы карты так, чтобы маршрут был виден целиком.
            boundsAutoApply: true
        }
    );

    // Добавление маршрута на карту.
    multiRoute.editor.start();
    myMap.geoObjects.add(multiRoute);
}