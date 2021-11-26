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
    console.log($('#lat').val());

    // const geocoder = new google.maps.Geocoder();
    // console.log(geocoder);

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

$('.country-select').on('change', function() {

    // Initialize latlang of countries
    let countryMap = countriesWithLatlang();

    let country = $(this).val();

    latLng = new google.maps.LatLng(countryMap.get(country).lat(), countryMap.get(country).lng());
    projectMarker.setPosition(latLng);
    projectMap.panTo(latLng);

    // $.ajax({
    //     url: 'https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyBDajNp54DtGem2vIo5drOiNpae5lCdQKY',
    //     method: 'GET',
    //     datatype: 'json',
    //     success: function(data){
    //         console.log(data);
    //     }
    // })

   

});


function countriesWithLatlang() {
    var myMap = new Map();

    myMap.set("Afghanistan", new google.maps.LatLng(33.93911,67.709953));
    myMap.set("United Arab Emirates", new google.maps.LatLng(23.424076,53.847818));
    myMap.set("Antigua and Barbuda", new google.maps.LatLng(17.060816,-61.796428));
    myMap.set("Anguilla", new google.maps.LatLng(18.220554,-63.068615));
    myMap.set("Albania", new google.maps.LatLng(41.153332,20.168331));
    myMap.set("Armenia", new google.maps.LatLng(40.069099,45.038189));
    myMap.set("Netherlands Antilles", new google.maps.LatLng(12.226079,-69.060087));
    myMap.set("Angola", new google.maps.LatLng(-11.202692,17.873887));
    myMap.set("Antarctica", new google.maps.LatLng(-75.250973,-0.071389));
    myMap.set("Argentina", new google.maps.LatLng(-38.416097,-63.616672));
    myMap.set("American Samoa", new google.maps.LatLng(-14.270972,-170.132217));
    myMap.set("Austria", new google.maps.LatLng(47.516231,14.550072));
    myMap.set("Australia", new google.maps.LatLng(-25.274398,133.775136));
    myMap.set("AD", new google.maps.LatLng(42.546245,1.601554));
    myMap.set("Aruba", new google.maps.LatLng(12.52111,-69.968338));
    myMap.set("Azerbaijan", new google.maps.LatLng(40.143105,47.576927));
    myMap.set("Bosnia and Herzegovina", new google.maps.LatLng(43.915886,17.679076));
    myMap.set("Barbados", new google.maps.LatLng(13.193887,-59.543198));
    myMap.set("Bangladesh", new google.maps.LatLng(23.684994,90.356331));
    myMap.set("Belgium", new google.maps.LatLng(50.503887,4.469936));
    myMap.set("Burkina Faso", new google.maps.LatLng(12.238333,-1.561593));
    myMap.set("Bulgaria", new google.maps.LatLng(42.733883,25.48583));
    myMap.set("Bahrain", new google.maps.LatLng(25.930414,50.637772));
    myMap.set("Burundi", new google.maps.LatLng(-3.373056,29.918886));
    myMap.set("Benin", new google.maps.LatLng(9.30769,2.315834));
    myMap.set("Bermuda", new google.maps.LatLng(32.321384,-64.75737));
    myMap.set("Brunei", new google.maps.LatLng(4.535277,114.727669));
    myMap.set("BO", new google.maps.LatLng(-16.290154,-63.588653));
    myMap.set("BR", new google.maps.LatLng(-14.235004,-51.92528));
    myMap.set("BS", new google.maps.LatLng(25.03428,-77.39628));
    myMap.set("BT", new google.maps.LatLng(27.514162,90.433601));
    myMap.set("BV", new google.maps.LatLng(-54.423199,3.413194));
    myMap.set("BW", new google.maps.LatLng(-22.328474,24.684866));
    myMap.set("BY", new google.maps.LatLng(53.709807,27.953389));
    myMap.set("BZ", new google.maps.LatLng(17.189877,-88.49765));
    myMap.set("CA", new google.maps.LatLng(56.130366,-106.346771));
    myMap.set("CC", new google.maps.LatLng(-12.164165,96.870956));
    myMap.set("CD", new google.maps.LatLng(-4.038333,21.758664));
    myMap.set("CF", new google.maps.LatLng(6.611111,20.939444));
    myMap.set("CG", new google.maps.LatLng(-0.228021,15.827659));
    myMap.set("CH", new google.maps.LatLng(46.818188,8.227512));
    myMap.set("CI", new google.maps.LatLng(7.539989,-5.54708));
    myMap.set("CK", new google.maps.LatLng(-21.236736,-159.777671));
    myMap.set("CL", new google.maps.LatLng(-35.675147,-71.542969));
    myMap.set("CM", new google.maps.LatLng(7.369722,12.354722));
    myMap.set("CN", new google.maps.LatLng(35.86166,104.195397));
    myMap.set("CO", new google.maps.LatLng(4.570868,-74.297333));
    myMap.set("CR", new google.maps.LatLng(9.748917,-83.753428));
    myMap.set("CU", new google.maps.LatLng(21.521757,-77.781167));
    myMap.set("CV", new google.maps.LatLng(16.002082,-24.013197));
    myMap.set("CX", new google.maps.LatLng(-10.447525,105.690449));
    myMap.set("CY", new google.maps.LatLng(35.126413,33.429859));
    myMap.set("CZ", new google.maps.LatLng(49.817492,15.472962));
    myMap.set("DE", new google.maps.LatLng(51.165691,10.451526));
    myMap.set("DJ", new google.maps.LatLng(11.825138,42.590275));
    myMap.set("DK", new google.maps.LatLng(56.26392,9.501785));
    myMap.set("DM", new google.maps.LatLng(15.414999,-61.370976));
    myMap.set("DO", new google.maps.LatLng(18.735693,-70.162651));
    myMap.set("DZ", new google.maps.LatLng(28.033886,1.659626));
    myMap.set("EC", new google.maps.LatLng(-1.831239,-78.183406));
    myMap.set("EE", new google.maps.LatLng(58.595272,25.013607));
    myMap.set("EG", new google.maps.LatLng(26.820553,30.802498));
    myMap.set("EH", new google.maps.LatLng(24.215527,-12.885834));
    myMap.set("ER", new google.maps.LatLng(15.179384,39.782334));
    myMap.set("ES", new google.maps.LatLng(40.463667,-3.74922));
    myMap.set("ET", new google.maps.LatLng(9.145,40.489673));
    myMap.set("FI", new google.maps.LatLng(61.92411,25.748151));
    myMap.set("FJ", new google.maps.LatLng(-16.578193,179.414413));
    myMap.set("FK", new google.maps.LatLng(-51.796253,-59.523613));
    myMap.set("FM", new google.maps.LatLng(7.425554,150.550812));
    myMap.set("FO", new google.maps.LatLng(61.892635,-6.911806));
    myMap.set("FR", new google.maps.LatLng(46.227638,2.213749));
    myMap.set("GA", new google.maps.LatLng(-0.803689,11.609444));
    myMap.set("GB", new google.maps.LatLng(55.378051,-3.435973));
    myMap.set("GD", new google.maps.LatLng(12.262776,-61.604171));
    myMap.set("GE", new google.maps.LatLng(42.315407,43.356892));
    myMap.set("GF", new google.maps.LatLng(3.933889,-53.125782));
    myMap.set("GG", new google.maps.LatLng(49.465691,-2.585278));
    myMap.set("GH", new google.maps.LatLng(7.946527,-1.023194));
    myMap.set("GI", new google.maps.LatLng(36.137741,-5.345374));
    myMap.set("GL", new google.maps.LatLng(71.706936,-42.604303));
    myMap.set("GM", new google.maps.LatLng(13.443182,-15.310139));
    myMap.set("GN", new google.maps.LatLng(9.945587,-9.696645));
    myMap.set("GP", new google.maps.LatLng(16.995971,-62.067641));
    myMap.set("GQ", new google.maps.LatLng(1.650801,10.267895));
    myMap.set("GR", new google.maps.LatLng(39.074208,21.824312));
    myMap.set("GS", new google.maps.LatLng(-54.429579,-36.587909));
    myMap.set("GT", new google.maps.LatLng(15.783471,-90.230759));
    myMap.set("GU", new google.maps.LatLng(13.444304,144.793731));
    myMap.set("GW", new google.maps.LatLng(11.803749,-15.180413));
    myMap.set("GY", new google.maps.LatLng(4.860416,-58.93018));
    myMap.set("GZ", new google.maps.LatLng(31.354676,34.308825));
    myMap.set("HK", new google.maps.LatLng(22.396428,114.109497));
    myMap.set("HM", new google.maps.LatLng(-53.08181,73.504158));
    myMap.set("HN", new google.maps.LatLng(15.199999,-86.241905));
    myMap.set("HR", new google.maps.LatLng(45.1,15.2));
    myMap.set("HT", new google.maps.LatLng(18.971187,-72.285215));
    myMap.set("HU", new google.maps.LatLng(47.162494,19.503304));
    myMap.set("ID", new google.maps.LatLng(-0.789275,113.921327));
    myMap.set("IE", new google.maps.LatLng(53.41291,-8.24389));
    myMap.set("IL", new google.maps.LatLng(31.046051,34.851612));
    myMap.set("IM", new google.maps.LatLng(54.236107,-4.548056));
    myMap.set("India", new google.maps.LatLng(20.593684,78.96288));
    myMap.set("IO", new google.maps.LatLng(-6.343194,71.876519));
    myMap.set("IQ", new google.maps.LatLng(33.223191,43.679291));
    myMap.set("IR", new google.maps.LatLng(32.427908,53.688046));
    myMap.set("IS", new google.maps.LatLng(64.963051,-19.020835));
    myMap.set("IT", new google.maps.LatLng(41.87194,12.56738));
    myMap.set("JE", new google.maps.LatLng(49.214439,-2.13125));
    myMap.set("JM", new google.maps.LatLng(18.109581,-77.297508));
    myMap.set("JO", new google.maps.LatLng(30.585164,36.238414));
    myMap.set("JP", new google.maps.LatLng(36.204824,138.252924));
    myMap.set("KE", new google.maps.LatLng(-0.023559,37.906193));
    myMap.set("KG", new google.maps.LatLng(41.20438,74.766098));
    myMap.set("KH", new google.maps.LatLng(12.565679,104.990963));
    myMap.set("KI", new google.maps.LatLng(-3.370417,-168.734039));
    myMap.set("KM", new google.maps.LatLng(-11.875001,43.872219));
    myMap.set("KN", new google.maps.LatLng(17.357822,-62.782998));
    myMap.set("KP", new google.maps.LatLng(40.339852,127.510093));
    myMap.set("KR", new google.maps.LatLng(35.907757,127.766922));
    myMap.set("KW", new google.maps.LatLng(29.31166,47.481766));
    myMap.set("KY", new google.maps.LatLng(19.513469,-80.566956));
    myMap.set("KZ", new google.maps.LatLng(48.019573,66.923684));
    myMap.set("LA", new google.maps.LatLng(19.85627,102.495496));
    myMap.set("LB", new google.maps.LatLng(33.854721,35.862285));
    myMap.set("LC", new google.maps.LatLng(13.909444,-60.978893));
    myMap.set("LI", new google.maps.LatLng(47.166,9.555373));
    myMap.set("LK", new google.maps.LatLng(7.873054,80.771797));
    myMap.set("LR", new google.maps.LatLng(6.428055,-9.429499));
    myMap.set("LS", new google.maps.LatLng(-29.609988,28.233608));
    myMap.set("LT", new google.maps.LatLng(55.169438,23.881275));
    myMap.set("LU", new google.maps.LatLng(49.815273,6.129583));
    myMap.set("LV", new google.maps.LatLng(56.879635,24.603189));
    myMap.set("LY", new google.maps.LatLng(26.3351,17.228331));
    myMap.set("MA", new google.maps.LatLng(31.791702,-7.09262));
    myMap.set("MC", new google.maps.LatLng(43.750298,7.412841));
    myMap.set("MD", new google.maps.LatLng(47.411631,28.369885));
    myMap.set("ME", new google.maps.LatLng(42.708678,19.37439));
    myMap.set("MG", new google.maps.LatLng(-18.766947,46.869107));
    myMap.set("MH", new google.maps.LatLng(7.131474,171.184478));
    myMap.set("MK", new google.maps.LatLng(41.608635,21.745275));
    myMap.set("ML", new google.maps.LatLng(17.570692,-3.996166));
    myMap.set("MM", new google.maps.LatLng(21.913965,95.956223));
    myMap.set("MN", new google.maps.LatLng(46.862496,103.846656));
    myMap.set("MO", new google.maps.LatLng(22.198745,113.543873));
    myMap.set("MP", new google.maps.LatLng(17.33083,145.38469));
    myMap.set("MQ", new google.maps.LatLng(14.641528,-61.024174));
    myMap.set("MR", new google.maps.LatLng(21.00789,-10.940835));
    myMap.set("MS", new google.maps.LatLng(16.742498,-62.187366));
    myMap.set("MT", new google.maps.LatLng(35.937496,14.375416));
    myMap.set("MU", new google.maps.LatLng(-20.348404,57.552152));
    myMap.set("MV", new google.maps.LatLng(3.202778,73.22068));
    myMap.set("MW", new google.maps.LatLng(-13.254308,34.301525));
    myMap.set("MX", new google.maps.LatLng(23.634501,-102.552784));
    myMap.set("MY", new google.maps.LatLng(4.210484,101.975766));
    myMap.set("MZ", new google.maps.LatLng(-18.665695,35.529562));
    myMap.set("NA", new google.maps.LatLng(-22.95764,18.49041));
    myMap.set("NC", new google.maps.LatLng(-20.904305,165.618042));
    myMap.set("NE", new google.maps.LatLng(17.607789,8.081666));
    myMap.set("NF", new google.maps.LatLng(-29.040835,167.954712));
    myMap.set("NG", new google.maps.LatLng(9.081999,8.675277));
    myMap.set("NI", new google.maps.LatLng(12.865416,-85.207229));
    myMap.set("NL", new google.maps.LatLng(52.132633,5.291266));
    myMap.set("NO", new google.maps.LatLng(60.472024,8.468946));
    myMap.set("NP", new google.maps.LatLng(28.394857,84.124008));
    myMap.set("NR", new google.maps.LatLng(-0.522778,166.931503));
    myMap.set("NU", new google.maps.LatLng(-19.054445,-169.867233));
    myMap.set("NZ", new google.maps.LatLng(-40.900557,174.885971));
    myMap.set("OM", new google.maps.LatLng(21.512583,55.923255));
    myMap.set("PA", new google.maps.LatLng(8.537981,-80.782127));
    myMap.set("PE", new google.maps.LatLng(-9.189967,-75.015152));
    myMap.set("PF", new google.maps.LatLng(-17.679742,-149.406843));
    myMap.set("PG", new google.maps.LatLng(-6.314993,143.95555));
    myMap.set("PH", new google.maps.LatLng(12.879721,121.774017));
    myMap.set("PK", new google.maps.LatLng(30.375321,69.345116));
    myMap.set("PL", new google.maps.LatLng(51.919438,19.145136));
    myMap.set("PM", new google.maps.LatLng(46.941936,-56.27111));
    myMap.set("PN", new google.maps.LatLng(-24.703615,-127.439308));
    myMap.set("PR", new google.maps.LatLng(18.220833,-66.590149));
    myMap.set("PS", new google.maps.LatLng(31.952162,35.233154));
    myMap.set("PT", new google.maps.LatLng(39.399872,-8.224454));
    myMap.set("PW", new google.maps.LatLng(7.51498,134.58252));
    myMap.set("PY", new google.maps.LatLng(-23.442503,-58.443832));
    myMap.set("QA", new google.maps.LatLng(25.354826,51.183884));
    myMap.set("RE", new google.maps.LatLng(-21.115141,55.536384));
    myMap.set("RO", new google.maps.LatLng(45.943161,24.96676));
    myMap.set("RS", new google.maps.LatLng(44.016521,21.005859));
    myMap.set("RU", new google.maps.LatLng(61.52401,105.318756));
    myMap.set("RW", new google.maps.LatLng(-1.940278,29.873888));
    myMap.set("SA", new google.maps.LatLng(23.885942,45.079162));
    myMap.set("SB", new google.maps.LatLng(-9.64571,160.156194));
    myMap.set("SC", new google.maps.LatLng(-4.679574,55.491977));
    myMap.set("SD", new google.maps.LatLng(12.862807,30.217636));
    myMap.set("SE", new google.maps.LatLng(60.128161,18.643501));
    myMap.set("SG", new google.maps.LatLng(1.352083,103.819836));
    myMap.set("SH", new google.maps.LatLng(-24.143474,-10.030696));
    myMap.set("SI", new google.maps.LatLng(46.151241,14.995463));
    myMap.set("SJ", new google.maps.LatLng(77.553604,23.670272));
    myMap.set("SK", new google.maps.LatLng(48.669026,19.699024));
    myMap.set("SL", new google.maps.LatLng(8.460555,-11.779889));
    myMap.set("SM", new google.maps.LatLng(43.94236,12.457777));
    myMap.set("SN", new google.maps.LatLng(14.497401,-14.452362));
    myMap.set("SO", new google.maps.LatLng(5.152149,46.199616));
    myMap.set("SR", new google.maps.LatLng(3.919305,-56.027783));
    myMap.set("ST", new google.maps.LatLng(0.18636,6.613081));
    myMap.set("SV", new google.maps.LatLng(13.794185,-88.89653));
    myMap.set("SY", new google.maps.LatLng(34.802075,38.996815));
    myMap.set("SZ", new google.maps.LatLng(-26.522503,31.465866));
    myMap.set("TC", new google.maps.LatLng(21.694025,-71.797928));
    myMap.set("TD", new google.maps.LatLng(15.454166,18.732207));
    myMap.set("TF", new google.maps.LatLng(-49.280366,69.348557));
    myMap.set("TG", new google.maps.LatLng(8.619543,0.824782));
    myMap.set("TH", new google.maps.LatLng(15.870032,100.992541));
    myMap.set("TJ", new google.maps.LatLng(38.861034,71.276093));
    myMap.set("TK", new google.maps.LatLng(-8.967363,-171.855881));
    myMap.set("TL", new google.maps.LatLng(-8.874217,125.727539));
    myMap.set("TM", new google.maps.LatLng(38.969719,59.556278));
    myMap.set("TN", new google.maps.LatLng(33.886917,9.537499));
    myMap.set("TO", new google.maps.LatLng(-21.178986,-175.198242));
    myMap.set("TR", new google.maps.LatLng(38.963745,35.243322));
    myMap.set("TT", new google.maps.LatLng(10.691803,-61.222503));
    myMap.set("TV", new google.maps.LatLng(-7.109535,177.64933));
    myMap.set("TW", new google.maps.LatLng(23.69781,120.960515));
    myMap.set("TZ", new google.maps.LatLng(-6.369028,34.888822));
    myMap.set("UA", new google.maps.LatLng(48.379433,31.16558));
    myMap.set("UG", new google.maps.LatLng(1.373333,32.290275));
    myMap.set("US", new google.maps.LatLng(37.09024,-95.712891));
    myMap.set("UY", new google.maps.LatLng(-32.522779,-55.765835));
    myMap.set("UZ", new google.maps.LatLng(41.377491,64.585262));
    myMap.set("VA", new google.maps.LatLng(41.902916,12.453389));
    myMap.set("VC", new google.maps.LatLng(12.984305,-61.287228));
    myMap.set("VE", new google.maps.LatLng(6.42375,-66.58973));
    myMap.set("VG", new google.maps.LatLng(18.420695,-64.639968));
    myMap.set("VI", new google.maps.LatLng(18.335765,-64.896335));
    myMap.set("VN", new google.maps.LatLng(14.058324,108.277199));
    myMap.set("VU", new google.maps.LatLng(-15.376706,166.959158));
    myMap.set("WF", new google.maps.LatLng(-13.768752,-177.156097));
    myMap.set("WS", new google.maps.LatLng(-13.759029,-172.104629));
    myMap.set("XK", new google.maps.LatLng(42.602636,20.902977));
    myMap.set("YE", new google.maps.LatLng(15.552727,48.516388));
    myMap.set("YT", new google.maps.LatLng(-12.8275,45.166244));
    myMap.set("ZA", new google.maps.LatLng(-30.559482,22.937506));
    myMap.set("ZM", new google.maps.LatLng(-13.133897,27.849332));
    myMap.set("ZW", new google.maps.LatLng(-19.015438,29.154857));

    return myMap;
};
