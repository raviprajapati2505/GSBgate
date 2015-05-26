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
    projectMarker = gmaps.initializeMarker(projectMap, wkt.components[0].y, wkt.components[0].x, ($('#project_name').length > 0), function() {
        var updatedWkt = new Wkt.Wkt(projectMarker);
        $('#project_latlng').val(updatedWkt.write());
    });

    // Move the marker when one of the address fields is changed
    $('#project_address, #project_location, #project_country').change(function() {
        moveMarkerToProjectAddress();
    });
}

function moveMarkerToProjectAddress() {
    var addressFields = ['#project_address', '#project_location', '#project_country'];
    var address = '';
    var allFieldsFilled = true;

    // Format the address
    $.each(addressFields, function (index, field) {
        var fieldValue = $.trim($(field).val());

        if (fieldValue == '') {
            allFieldsFilled = false;
            return;
        }
        else {
            address += fieldValue + ' ';
        }
    });

    // Geocode the address
    if (allFieldsFilled) {
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
}
