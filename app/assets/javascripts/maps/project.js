$(document).ready(function () {
    handler = Gmaps.build('Google');
    handler.buildMap({
        provider: {
            zoom:      12,
            center:    new google.maps.LatLng(51.16194, 4.99139),
            mapTypeId: google.maps.MapTypeId.ROADMAP
        },
        internal: {
            id: 'map'
        }
    }, function () {

    });
});

