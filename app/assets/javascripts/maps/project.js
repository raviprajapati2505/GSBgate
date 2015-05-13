var projectMap;
var projectMarker;

$(function () {
    google.maps.event.addDomListener(window, 'load', initializeProjectMap);

    $("#geocode-project-address").click(function(e) {
        var location = gmaps.geocode($('#project_address').val(), function(location) {
            if (location != null) {
                projectMarker.setPosition(location);
                projectMap.panTo(location);

                var updatedWkt = new Wkt.Wkt(projectMarker);
                $('#project_latlng').val(updatedWkt.write());
            }
        });
    });
});

function initializeProjectMap() {
    // Create the map
    projectMap = gmaps.initializeMap();

    // Get the coordinates from the form
    var wkt = new Wkt.Wkt($('#project_latlng').val());

    // Initialize the marker, using the coordinates from the form
    projectMarker = gmaps.initializeMarker(projectMap, wkt.components[0].y, wkt.components[0].x, function() {
        var updatedWkt = new Wkt.Wkt(projectMarker);
        $('#project_latlng').val(updatedWkt.write());
    });
}
