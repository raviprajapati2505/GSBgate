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
    var coordinates = $('#project_coordinates').val().split(',');

    // Initialize a marker using the coordinates from the form
    projectMarker = gmaps.initializeMarker(projectMap, coordinates[0], coordinates[1], ($('#project_name').length > 0), function() {
        updateLatLngFields(projectMarker);
    });

    // Move the marker when one of the address fields is changed
    $('#project_address, #project_location, #project_country').change(function() {
        moveMarkerToProjectAddress();
    });

    // Move the marker when one of the lat lng fields is changed
    $('#lat, #lng').change(function() {
        moveMarkerToCoordinates();
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
        gmaps.geocode(address, function (latLng) {
            if (latLng != null) {
                // Move the marker to the geocoded location
                projectMarker.setPosition(latLng);
                projectMap.panTo(latLng);

                // Update the latlng & coordinates fields
                updateLatLngFields(projectMarker);
            }
        });
    }
}

function moveMarkerToCoordinates() {
    latLng = new google.maps.LatLng($('#lat').val(), $('#lng').val());

    // Validate the lat lng fields
    if (isNaN(latLng.lat()) || isNaN(latLng.lng())) {
        toastr.error('The Latitude and Longitude fields can only contain numbers.');
    }
    else {
        projectMarker.setPosition(latLng);
        projectMap.panTo(latLng);
    }

    // Update the latlng & coordinates fields
    updateLatLngFields(projectMarker);
}

function updateLatLngFields(projectMarker) {
    var markerPosition = projectMarker.getPosition();
    var markerLat = markerPosition.lat();
    var markerLng = markerPosition.lng();

    $('#project_coordinates').val(markerLat + ',' + markerLng);
    $('#lat').val(markerLat);
    $('#lng').val(markerLng);
}