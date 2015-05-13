var gmaps = {
    // Initializes a map
    initializeMap: function () {
        return new google.maps.Map(document.getElementById('map'), {
            zoom: 15,
            streetViewControl: false,
            panControl: false,
            zoomControlOptions: { style: google.maps.ZoomControlStyle.LARGE },
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });
    },
    // Initializes a marker on a map
    initializeMarker: function (map, lat, lng, callback) {
        // Create a point
        var latLng = new google.maps.LatLng(lat, lng);

        // Set the center of the map to this point
        map.setCenter(latLng);

        // Create a marker on this point
        var marker = new google.maps.Marker({
            position: latLng,
            map: map,
            draggable: true,
            animation: google.maps.Animation.DROP
        });

        // Add an event listener for marker dragging
        google.maps.event.addListener(marker, 'dragend', callback);

        return marker;
    },
    // Retrieves coordinates by an address string
    geocode: function (address, callback) {
        var geocoder = new google.maps.Geocoder();

        geocoder.geocode({
            address: address
        }, function (results, status) {
            if ((status == google.maps.GeocoderStatus.OK) && results && results.length > 0) {
                callback(results[0].geometry.location);
            }
        });
    }
}
