var projectMap;
var projectMarker;
var projectButton;

$(function () {
    google.maps.event.addDomListener(window, 'load', initializeProjectMap);
});

function initializeProjectMap() {
    // Create the map
    projectMap = gmaps.initializeMap('project-map');

    // Get the coordinates from the form
    var wkt = new Wkt.Wkt($('#project_latlng').val());

    // Initialize a marker using the coordinates from the form
    projectMarker = gmaps.initializeMarker(projectMap, wkt.components[0].y, wkt.components[0].x, function() {
        var updatedWkt = new Wkt.Wkt(projectMarker);
        $('#project_latlng').val(updatedWkt.write());
    });

    // Initialize a button
    projectButton = gmaps.initializeButton(
        projectMap,
        '<i class="fa fa-map-marker"></i>&nbsp;&nbsp;Move marker to project address',
        'This button will move the marker to the project address\nusing the contents of the Address, Location and Country fields.',
        moveMarkerToProjectAddress);
}

function moveMarkerToProjectAddress() {
    var address = $('#project_address').val() + ' ' + $('#project_location').val() + ' ' + $('#project_country').val();

    // Geocode the address
    gmaps.geocode(address, function (location) {
        if (location != null) {
            // Move the marker to the geocoded location
            projectMarker.setPosition(location);
            projectMap.panTo(location);

            // Update the WKT latlng text field
            var updatedWkt = new Wkt.Wkt(projectMarker);
            $('#project_latlng').val(updatedWkt.write());
        }
    });
}
