/**
 * Contains helper functions for the Google Maps JS API.
 */
var gmaps = {
    // Initializes a map
    initializeMap: function (id) {
        return new google.maps.Map(document.getElementById(id), {
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
    // Initializes a button on a map
    initializeButton: function (map, buttonHtml, buttonTitle, callback) {
        // Create a div wrapper
        var controlDiv = document.createElement('div');
        controlDiv.index = 1;

        // Set CSS for the control border
        var controlUI = document.createElement('div');
        controlUI.style.backgroundColor = '#fff';
        controlUI.style.border = '2px solid #fff';
        controlUI.style.borderRadius = '3px';
        controlUI.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
        controlUI.style.cursor = 'pointer';
        controlUI.style.marginTop = '8px';
        controlUI.style.textAlign = 'center';
        controlUI.title = buttonTitle;
        controlDiv.appendChild(controlUI);

        // Set CSS for the control interior
        var controlText = document.createElement('div');
        controlText.style.color = 'rgb(25,25,25)';
        controlText.style.fontFamily = 'Roboto,Arial,sans-serif';
        controlText.style.fontSize = '14px';
        controlText.style.lineHeight = '32px';
        controlText.style.paddingLeft = '5px';
        controlText.style.paddingRight = '5px';
        controlText.innerHTML = buttonHtml;
        controlUI.appendChild(controlText);

        // Add an event listener for a click on the button
        google.maps.event.addDomListener(controlUI, 'click', callback);

        // Add the button to the map controls
        map.controls[google.maps.ControlPosition.TOP_LEFT].push(controlDiv);
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
