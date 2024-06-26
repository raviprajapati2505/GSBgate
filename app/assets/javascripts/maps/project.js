var projectMap;
var projectMarker;
var projectButton;
var geocoder;

window.addEventListener('load', (evt => {
    initializeProjectMap()
}));

function initializeProjectMap() {
    // Create the map
    projectMap = gmaps.initializeMap('project-map');
    geocoder = new google.maps.Geocoder();

    // Get the coordinates from the form
    var coordinates = $('#project_coordinates').val().split(',');

    // Initialize a marker using the coordinates from the form
    projectMarker = gmaps.initializeMarker(projectMap, coordinates[0], coordinates[1], ($('#project_name').length > 0), function() {
        updateLatLngFields(projectMarker);
    });

    // Move the marker when one of the address fields is changed
    $('#project_address, #project_country').change(function() {
        moveMarkerToProjectAddress();
    });

    // Move the marker when one of the lat lng fields is changed
    $('#lat, #lng').change(function() {
        moveMarkerToCoordinates();
    });
}

function moveMarkerToProjectAddress() {
    var addressFields = ['#project_address', '#project_country'];
    var address = '';
    var allFieldsFilled = true;

    // Format the address
    $.each(addressFields, function (index, field) {
        let fieldValue = $.trim($(field).val());

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

                // Set the location field value in form
                set_location_value(latLng);

                // Update the latlng & coordinates fields
                updateLatLngFields(projectMarker);
            }
        });
    }
}

function moveMarkerToCoordinates() {
    let lat = $('#lat').val();
    let lng = $('#lng').val();
    
    latLng = new google.maps.LatLng(lat, lng);
    // Validate the lat lng fields
    if (isNaN(latLng.lat()) || isNaN(latLng.lng())) {
        toastr.error('The Latitude and Longitude fields can only contain numbers.');
    }
    else {
        projectMarker.setPosition(latLng);
        projectMap.panTo(latLng);
    }

    // Set the location field value in form
    set_location_value(latLng);

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

function set_location_value(latLng){
    geocoder.geocode( { 'location': latLng }, function(results, status) {
        if (status == 'OK') {
            $("#project_location").val(results[0].formatted_address);
            $("#search_location").val(results[0].formatted_address);
        } else {
            alert('Geocode was not successful for the following reason: ' + status);
        }
    });
}

$('button#submit-location-btn').on('click', function() {
    var address = $("#search_location").val();
    geocoder.geocode( { 'address': address }, function(results, status) {
        if (status == 'OK') {
            let lat = results[0].geometry.location.lat();
            let lng = results[0].geometry.location.lng();

            $('#lat').val(lat);
            $('#lng').val(lng);

            $("#project_location").val(results[0].formatted_address);

            moveMarkerToCoordinates();
          } else {
            alert('Geocode was not successful for the following reason: ' + status);
          }
    });
});
