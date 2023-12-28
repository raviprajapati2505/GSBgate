$(function(){

    $('#building-properties').html('<div class="col-md-4">' +
        '    <div class="ibox float-e-margins">' +
        '        <div class="ibox-title">' +
        '            <h5>Building map</h5>' +
        '        </div>' +
        '        <div class="ibox-content">' +
        '            <div id="building-map" class="map" style="height: 300px;"></div>' +
        '            <div class="hr-line-dashed"></div>' +
        '            <a id="draw-building-btn" class="btn btn-primary display-none"><i title="Draw building shape" class="fa fa-lg fa-edit" style="padding-right: 10px;"></i>Draw</a>' +
        '            <a id="edit-building-btn" class="btn btn-primary display-none"><i title="Edit building shape" class="fa fa-lg fa-edit" style="padding-right: 10px;"></i>Edit</a>' +
        '            <a id="remove-building-btn" class="btn btn-danger display-none"><i title="Remove building shape" class="fa fa-lg fa-trash-o" style="padding-right: 10px;"></i>Remove</a>' +
        '        </div>' +
        '    </div>' +
        '</div>' +
        '<div class="col-md-4">' +
        '    <div class="ibox float-e-margins">' +
        '        <div class="ibox-title">' +
        '            <h5>Building details</h5>' +
        '        </div>' +
        '        <div class="ibox-content">' +
        '            <table class="table table-bordered table-striped">' +
        '                <tbody>' +
        '                <tr id="building-height">' +
        '                    <th>Building height</th>' +
        '                    <td></td>' +
        '                </tr>' +
        '                </tbody>' +
        '            </table>' +
        '            <table class="table table-bordered table-striped">' +
        '                <tbody id="building-facade-tb">' +
        '                </tbody>' +
        '            </table>' +
        '        </div>' +
        '    </div>' +
        '</div>' +
        '<div class="col-md-4">' +
        '    <div class="ibox float-e-margins">' +
        '        <div class="ibox-title">' +
        '            <h5>3D visualisation</h5>' +
        '        </div>' +
        '        <div class="ibox-content">' +
        '            <div id="viewport" style="height: 300px;"></div>' +
        '            <div class="hr-line-dashed"></div>' +
        '            <a id="save-building-btn" class="btn btn-primary"><i title="Save building" class="fa fa-lg fa-save" style="padding-right: 10px;"></i>Save</a>' +
        '        </div>' +
        '    </div>' +
        '</div>');

    // test to add dialog window (not in use)

    // $('body').append('<div id="myModal" class="modal fade">' +
    // '  <div class="modal-dialog" style="width: auto !important; margin: 30px !important">' +
    // '    <div class="modal-content">' +
    // '      <div class="modal-header">' +
    // '        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
    // '        <h4 class="modal-title">Building</h4>' +
    // '      </div>' +
    // '      <div class="modal-body">' +
    // '<div class="row">' +
    // '<div class="col-md-8">'+
    // '    <div class="ibox float-e-margins">'+
    // '        <div class="ibox-title">'+
    // '            <h5>Building map</h5>'+
    // '        </div>'+
    // '        <div class="ibox-content">' +
    // '            <input type="hidden" id="project_latlng" value="POINT (-4.2699596999999585 55.8662876)" /> '+
    // '            <div id="draw-map" class="map" style="height: 300px;"></div>'+
    // '            <div class="hr-line-dashed"></div>'+
    // '            <a class="btn btn-primary" href="/projects/7/edit"><i title="Edit project" class="fa fa-lg fa-edit" style="padding-right: 10px;"></i>Edit</a>' +
    // '        </div>' +
    // '    </div>'+
    // '</div>' +
    // '<div class="col-md-4">' +
    // '    <div class="ibox float-e-margins">' +
    // '        <div class="ibox-title">' +
    // '            <h5>Building details</h5>' +
    // '        </div>' +
    // '        <div class="ibox-content">' +
    // '            <table class="table table-bordered table-striped">' +
    // '                <tbody>' +
    // '                <tr>' +
    // '                    <th>Project ID</th>' +
    // '                    <td>TBC</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Project name</th>' +
    // '                    <td>Test project</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Description</th>' +
    // '                    <td>A test project</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Address</th>' +
    // '                    <td>Test</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Location</th>' +
    // '                    <td>test</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Country</th>' +
    // '                    <td>test</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                  <th>Construction year</th>' +
    // '                  <td>2015</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Gross area</th>' +
    // '                    <td>200 m²</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Certified area</th>' +
    // '                    <td>3000 m²</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Car park area</th>' +
    // '                    <td>300 m²</td>' +
    // '                </tr>' +
    // '                <tr>' +
    // '                    <th>Project site area</th>' +
    // '                    <td>4500 m²</td>' +
    // '                </tr>' +
    // '                </tbody>' +
    // '            </table>' +
    // '            <div class="hr-line-dashed"></div>' +
    // '            <a class="btn btn-primary" href="/projects/7/edit"><i title="Edit project" class="fa fa-lg fa-edit" style="padding-right: 10px;"></i>Edit</a>' +
    // '        </div>' +
    // '    </div>'+
    // '</div>' +
    // '</div>' +
    // '      </div>' +
    // '      <div class="modal-footer">' +
    // '        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>' +
    // '        <button type="button" class="btn btn-primary">Save changes</button>' +
    // '      </div>' +
    // '    </div><!-- /.modal-content -->' +
    // '  </div><!-- /.modal-dialog -->' +
    // '</div><!-- /.modal -->');


    // trigger the dialog window

    // $('#building-map').click(function() {
    //     $('#myModal').modal({
    //         keyboard: false
    //     });
    // });

    // this is found in html/global?
    var buildingId = 1234;

    var toMercator = proj4('EPSG:3857');

    var buildingFacadeTableBodyEl, drawBtn, editBtn, removeBtn, buildingHeightTrEl, viewportEl;

    var map;
    // layer references when draw and editing
    var drawLayer, editing, buildingLayer;

    var camera, scene, renderer, projector, controls;
    // 3d building mesh reference
    var building3d, ground3d;

    //var geojsonParam = JSON.parse(getUrlParameter('json'));

    // existing mock data "from the server"

    // var existingBuildingData = {
    //     geoJson: geojsonParam
    // };

    // if(!existingBuildingData.geoJson.properties.glazing) {
    //     existingBuildingData.geoJson.properties.glazing = [];
    // }
    // if(!existingBuildingData.geoJson.properties.height) {
    //     existingBuildingData.geoJson.properties.height = 10;
    // }

    var existingBuildingData;

    $(window).load(function(){

        $.get('/ssApi/buildings/' + buildingId, function(data) {

            existingBuildingData = data || createNewBuilding();

            init(existingBuildingData);

        });

    });

    function initCss() {

        $('.diplay-none').css({display: 'none'});

    }

    function initHtmlSelectors() {
        buildingFacadeTableBodyEl = $('#building-facade-tb');
        drawBtn = $('#draw-building-btn');
        editBtn = $('#edit-building-btn');
        removeBtn = $('#remove-building-btn');
        buildingHeightTrEl = $('#building-height');
        viewportEl = $('#viewport');
        saveBtn = $('#save-building-btn');

        saveBtn.click(function(e) {
            saveCurrentBuilding();
        });
    }

    function saveCurrentBuilding() {
        console.log(existingBuildingData);
        $.post('/ssApi/buildings', {buildingData: JSON.stringify(existingBuildingData)}, function(data, status) {
            console.log(data, status);
        });
    }

    function startEdit() {
        buildingLayer.eachLayer(function(l) {
            l.editing.enable();
        });

        editBtn.removeClass('btn-primary').addClass('btn-default').html('<i title="Save building shape" class="fa fa-lg fa-floppy-o" style="padding-right: 10px;"></i>Save</a>');

        editing = true;
    }

    function stopEdit() {
        if(editing) {
            buildingLayer.eachLayer(function(l) {
                l.editing.disable();
                // TODO: how to handle buildings with several bodies?
                // now assume there's always only one layer..
                updateGeometry(l);
            });
        }

        editBtn.removeClass('btn-default').addClass('btn-primary').html('<i title="Edit building shape" class="fa fa-lg fa-edit" style="padding-right: 10px;"></i>Edit</a>');

        editing = false;
    }

    function updateZoomLevel(buildingData) {
        buildingData.mapSettings = buildingData.mapSettings || {};
        buildingData.mapSettings.zoomLevel = map.getZoom();
    }

    function updateGeometry(layer) {
        // preserve propertes
        existingBuildingData.geoJson.geometry = layer.toGeoJSON().geometry;
        updateGlazingControls();
        updateViewport(existingBuildingData);
    }

    function updateGlazingControls() {

        var i, polygonData, glazingData;
        if(existingBuildingData.geoJson) {
            glazingData = existingBuildingData.geoJson.properties.glazing || [];
            polygonData = existingBuildingData.geoJson.geometry.coordinates;
            // update building properties from existingBuilding
            buildingFacadeTableBodyEl.empty();

            for(i = 0; i < polygonData.length; i++) {
                var trEl, glazing, p1 = polygonData[i];
                for(j = 1; j < p1.length; j++) {
                    glazing = getGlazing(glazingData, i, j-1);
                    trEl = $('<tr><th>Facade ' + j + ' glazing</th><td class="glazing-val">' + glazing + ' %<i title="Edit facade glazing" class="fa fa-lg fa-edit" style="padding-left: 10px;cursor: pointer"></i></td></tr>');
                    trEl.data('glazing', {glazing: glazing, i: i, j: j-1});
                    trEl.on('click', attachFacadeInput);
                    buildingFacadeTableBodyEl.append(trEl);
                }
            }

        }

    }

    function updateBuildingHeightControl() {
        var height = existingBuildingData.geoJson.properties.height;
        var hEl = buildingHeightTrEl.find('td');
        hEl.html(height + ' m <i title="Edit building height" class="fa fa-lg fa-edit" style="padding-left: 10px;cursor: pointer"></i>');
        buildingHeightTrEl.click(function() {
            var inputEl = $('<input type="text">').val(height);

            buildingHeightTrEl.off('click');
            hEl.empty().append(inputEl);
            hEl.append('<i title="Save building height" class="fa fa-lg fa-floppy-o" style="padding-left: 10px;cursor: pointer"></i>');

            inputEl.focus();

            inputEl.on('blur', function() {
                buildingHeightTrEl.off('click');
                existingBuildingData.geoJson.properties.height = inputEl.val();
                updateBuildingHeightControl();
                updateViewport(existingBuildingData);
            });
        });
    }

    function attachFacadeInput(e) {
        var trEl = $(this);
        var glazingData = $(this).data('glazing');
        var inputEl = $('<input type="text">').val(glazingData.glazing);

        trEl.off('click');
        trEl.find('.glazing-val').empty().append(inputEl).append('<i title="Save facade glazing" class="fa fa-lg fa-floppy-o" style="padding-left: 10px;cursor: pointer"></i>');

        inputEl.focus();

        inputEl.on('blur', function() {
            var existingGlazing = existingBuildingData.geoJson.properties.glazing;
            existingGlazing[glazingData] = existingGlazing[glazingData] || [];
            existingBuildingData.geoJson.properties.glazing[glazingData.i][glazingData.j] = inputEl.val();
            updateGlazingControls();
            updateViewport(existingBuildingData);
        });
    }

    function initMap() {
        map = L.map('building-map', {
            zoomControl: false
        }).setView([50.736455, 6.328125], 2);

        $('.leaflet-control-container').css({display: 'none'});

        L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.{ext}', {
            type: 'map',
            ext: 'jpg',
            attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
            subdomains: '1234'
        }).addTo(map);

        // layers for Leaflet Draw
        var drawnItems = new L.FeatureGroup();
        map.addLayer(drawnItems);

        var options = {
            draw: {
                polyline: false,
                rectangle: false,
                circle: false,
                marker: false,
                polygon: {
                    allowIntersection: false,
                    guidelineDistance: 1,
                    drawError: {
                        color: '#e1e100',
                        message: 'Polygon can not intersect!'
                    },
                    shapeOptions: {
                        color: 'rgba(66, 139, 202, 1)',
                        weight: 1
                    }
                }
            },
            edit: {
                featureGroup: drawnItems
            }
        };

        console.log(map.getZoom());

        var drawControl = new L.Control.Draw(options);

        buildingLayer = L.geoJson().addTo(map);
        // TODO: validate this in a nice way
        if(existingBuildingData.geoJson &&
            existingBuildingData.geoJson.geometry &&
            existingBuildingData.geoJson.geometry.coordinates &&
            existingBuildingData.geoJson.geometry.coordinates.length > 0) {
            buildingLayer.addData(existingBuildingData.geoJson);
            map.fitBounds(buildingLayer.getBounds());
            console.log(map.getZoom());

        }

        existingBuildingData.mapSettings.zoomLevel = map.getZoom();

        // wait for the map to adjust to building bounds before updating viewport
        map.on('moveend', function(e) {
            console.log(map.getZoom());
            updateViewport(existingBuildingData);
        });

        buildingLayer.on('click', function(e) {
            startEdit(e.layer);
        });

        map.on('click', function(e) {
            stopEdit();
        });

        drawBtn.click(function() {
            drawLayer = new L.Draw.Polygon(map, options.draw.polygon);
            drawLayer.addHooks();

            drawBtn.removeClass('btn-primary').addClass('btn-default');
        });

        editBtn.click(function() {
            if(!editing) {
                startEdit();
            } else {
                stopEdit();
            }
        });

        removeBtn.click(function() {
            buildingLayer.clearLayers();
            existingBuildingData.geoJson.geometry.coordinates = [];
            updateGlazingControls();
            updateViewport(existingBuildingData);
            updateButtons(existingBuildingData);
        });

        map.addControl(drawControl);

        map.on('draw:created', function (e) {
            var layer = e.layer;
            buildingLayer.addLayer(layer);
            drawLayer.removeHooks();
            drawBtn.removeClass('btn-default').addClass('btn-primary');
            updateZoomLevel(existingBuildingData);
            updateGeometry(layer);
            updateGlazingControls();
            updateButtons(existingBuildingData);
        });

        map.on('draw:drawstart', function (e) {
            console.log('draw:drawstart');
            e.target.eachLayer(function(l) {
                console.log(l);
                buildingLayer.removeLayer(l);
            });
        });

        map.on('draw:edited', function (e) {
            var layers = e.layers;
            layers.eachLayer(function (layer) {
                console.log(layer);
            });
            console.log('draw:edited');
            stopEdit();
        });

    }

    // this function takes the existing building data
    // and add some mandatory properties if not already exists
    function initBuildingData(buildingData) {

        buildingData = buildingData || {};

        buildingData.geoJson = buildingData.geoJson || {
                geometry: {
                    coordinates: [],
                    type: "Polygon"
                },
                properties: {
                    glazing: [],
                    height: 1
                },
                type: "Feature"
            };

        buildingData.geoJson.properties = buildingData.geoJson.properties || {
                glazing: [],
                height: 1
            };

        buildingData.mapSettings = buildingData.mapSettings || {
                zoomLevel: 12
            };
    }

    function init(buildingData) {
        initHtmlSelectors();
        initCss();
        initBuildingData(buildingData);
        initMap();
        updateButtons(buildingData);
        updateGlazingControls();
        updateBuildingHeightControl();
        initViewport();
        render();
        // the update is done on bounds change event (moveend) because asynchronous operation when loading building
        updateViewport(buildingData);
    }

    function updateButtons(buildingData) {
        if(buildingData.geoJson.geometry.coordinates.length > 0) {
            drawBtn.hide();
            editBtn.show();
            removeBtn.show();
        } else {
            drawBtn.show();
            editBtn.hide();
            removeBtn.hide();
        }
    }

    function getGlazing(glazingData, p1, p2) {
        // get glazing for this polygon
        var glazingPoly = glazingData[p1];
        // if glazing is not set for this polygon
        if(!glazingPoly) {
            glazingPoly = [];
            glazingData.push(glazingPoly);
        }
        // get the glazing value
        glazing = glazingPoly[p2];
        // if glazing value is not set for this facade
        if(!glazing && glazing !== 0) {
            glazing = 0;
            glazingPoly.push(glazing);
        }
        return glazing;
    }

    function initViewport() {

        camera = new THREE.PerspectiveCamera( 45, viewportEl.width() / viewportEl.height(), 10000, 20000000 );
        scene = new THREE.Scene();

        // Lights

        scene.add( new THREE.AmbientLight( 0xcccccc ) );

        var light = new THREE.DirectionalLight( 0xffffff );
        light.position.set( 0, 1, 1 ).normalize();
        scene.add(light);

        renderer = new THREE.WebGLRenderer();
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.setSize(viewportEl.width(), viewportEl.height());
        renderer.setClearColor( 0xffffff, 1);

        viewportEl.append( renderer.domElement );

        window.addEventListener( 'resize', onWindowResize, false );

        // use orbitcontrol default
        // viewportEl[0].addEventListener( 'mousewheel', onMouseWheel, false );
        // viewportEl[0].addEventListener( 'DOMMouseScroll', onMouseWheel, false ); // firefox

    }

    function onWindowResize() {

        camera.aspect = viewportEl.width() / viewportEl.height();
        camera.updateProjectionMatrix();

        renderer.setSize( viewportEl.width(), viewportEl.height() );

    }

    function onMouseWheel( ev ){

        console.log(ev);

        ev.preventDefault();
        ev.stopPropagation();

        var delta = 0;

        if ( ev.wheelDelta !== undefined ) {
            // WebKit / Opera / Explorer 9
            delta = ev.wheelDelta;
        } else if ( ev.detail !== undefined ) {
            // Firefox
            delta = - ev.detail;
        }

        var factor = 10;

        var WIDTH = viewportEl.width();
        var HEIGHT = viewportEl.height();

        var mX = ( ev.clientX / WIDTH ) * 2 - 1;
        var mY = - ( ev.clientY / HEIGHT ) * 2 + 1;

        var vector = new THREE.Vector3(mX, mY, 1 );
        vector.unproject( camera );
        vector.sub( camera.position ).normalize();

        if( delta > 0 ){
            camera.position.x += vector.x * factor;
            camera.position.y += vector.y * factor;
            camera.position.z += vector.z * factor;
            controls.target.x += vector.x * factor;
            controls.target.y += vector.y * factor;
            controls.target.z += vector.z * factor;
        } else{
            camera.position.x -= vector.x * factor;
            camera.position.y -= vector.y * factor;
            camera.position.z -= vector.z * factor;
            controls.target.x -= vector.x * factor;
            controls.target.y -= vector.y * factor;
            controls.target.z -= vector.z * factor;
        }

        return false;
    }

    function render() {

        requestAnimationFrame( render );
        renderer.render( scene, camera );

    }

    function updateViewport(buildingData) {
        if(buildingData.geoJson.geometry.coordinates.length === 0) {
            return;
        }
        if(building3d) {
            scene.remove(building3d);
            building3d = null;
        }
        if(ground3d) {
            scene.remove(ground3d);
            ground3d = null;
        }
        // bounds and center of building
        var bounds = buildingLayer.getBounds();
        var layerCentroid = bounds.getCenter();
        var mercatorCentroid = toMercator.forward([layerCentroid.lng, layerCentroid.lat]);

        console.log(map.getZoom());

        // bounds of map
        var mapBounds = map.getBounds(),
            mapNorth = mapBounds.getNorth(),
            mapEast = mapBounds.getEast(),
            mapSouth = mapBounds.getSouth(),
            mapWest = mapBounds.getWest(),
            mapne = toMercator.forward([mapEast, mapNorth]),
            mapsw = toMercator.forward([mapWest, mapSouth]),
            mapRange = mapne[0]-mapsw[0];

        var zoom = map.getZoom();

        // 3d ground settings
        THREE.ImageUtils.crossOrigin = '';
        var imageQuery = "https://api.mapbox.com/v4/mapbox.streets/" + layerCentroid.lng + "," + layerCentroid.lat + "," + zoom + "/1024x1024.png?access_token=pk.eyJ1IjoiYW5kcmVhc3J1ZGVuYSIsImEiOiJkMDI4NTFlMjYwZTYwN2UzOTVmZTdhOWYzZDllMjhlZCJ9.gnOB9biEpo1QqdhUewn4TA",
            groundImage = THREE.ImageUtils.loadTexture(imageQuery),
            groundMaterial = new THREE.MeshBasicMaterial( {
                side: THREE.DoubleSide,
                map: groundImage
            });

        // building data
        var coords = buildingData.geoJson.geometry.coordinates[0],
            buildingHeight = buildingData.geoJson.properties.height,
            glazing = buildingData.geoJson.properties.glazing,
            footprint = [];

        // 3d settings
        var i, point,
            buildingShape = new THREE.Shape(),
            groundShape = new THREE.Shape(),
            geometry,
            material,
            color = 0x0040f0,
            extrudeSettings = { amount: buildingHeight, bevelEnabled: false, bevelSegments: 1, steps: 1, bevelSize: 1, bevelThickness: 1 };

        if(ground3d) {
            scene.remove(ground3d);
        }

        groundShape.moveTo(mercatorCentroid[0] - mapRange, mercatorCentroid[1] - mapRange);
        groundShape.lineTo(mercatorCentroid[0] - mapRange, mercatorCentroid[1] + mapRange);
        groundShape.lineTo(mercatorCentroid[0] + mapRange, mercatorCentroid[1] + mapRange);
        groundShape.lineTo(mercatorCentroid[0] + mapRange, mercatorCentroid[1] - mapRange);
        groundShape.lineTo(mercatorCentroid[0] - mapRange, mercatorCentroid[1] - mapRange);

        geometry = new THREE.ShapeGeometry( groundShape );

        ground3d = new THREE.Mesh( geometry, groundMaterial);

        assignUVs(geometry);

        ground3d.rotation.set( -90 * Math.PI / 180, 0, 0 );
        ground3d.translateZ((buildingHeight / 100) * -1);
        scene.add( ground3d );

        for(i = 0; i < coords.length; i++) {
            point = toMercator.forward([coords[i][0], coords[i][1]]);
            var x = point[0], y = point[1];
            if(i === 0) {
                buildingShape.moveTo(x, y);
            } else {
                buildingShape.lineTo(x, y);
            }
            footprint.push(point);
        }

        //var area = polygonArea(footprint);
        geometry = new THREE.ExtrudeGeometry( buildingShape, extrudeSettings );
        material = assignMaterials(geometry, footprint, glazing, buildingHeight);
        assignUVs(geometry);

        building3d = new THREE.Mesh( geometry, material );
        building3d.rotation.set( -90 * Math.PI / 180, 0, 0 );

        scene.add( building3d );

        camera = new THREE.PerspectiveCamera( 45, viewportEl.width() / viewportEl.height(), mapRange/3, mapRange*10 );
        controls = new THREE.OrbitControls( camera, viewportEl[0] );
        controls.target.set( mercatorCentroid[0], 0, -mercatorCentroid[1]);
        camera.position.set( mercatorCentroid[0], mapRange/2, -mercatorCentroid[1]+(mapRange));

        controls.update();

    }

    function assignUVs( geometry ){

        geometry.computeBoundingBox();

        var max     = geometry.boundingBox.max;
        var min     = geometry.boundingBox.min;

        var offset  = new THREE.Vector3(0 - min.x, 0 - min.y, 0 - min.z);
        var range   = new THREE.Vector3(max.x - min.x, max.y - min.y, max.z - min.z);

        geometry.faceVertexUvs[0] = [];

        geometry.faces.forEach(function(face) {

            var components = ['x', 'y', 'z'].sort(function(a, b) {
                return Math.abs(face.normal[a]) > Math.abs(face.normal[b]);
            });

            var v1 = geometry.vertices[face.a];
            var v2 = geometry.vertices[face.b];
            var v3 = geometry.vertices[face.c];

            geometry.faceVertexUvs[0].push([
                new THREE.Vector2((v1[components[0]] + offset[components[0]]) / range[components[0]], (v1[components[1]] + offset[components[1]]) / range[components[1]]),
                new THREE.Vector2((v2[components[0]] + offset[components[0]]) / range[components[0]], (v2[components[1]] + offset[components[1]]) / range[components[1]]),
                new THREE.Vector2((v3[components[0]] + offset[components[0]]) / range[components[0]], (v3[components[1]] + offset[components[1]]) / range[components[1]])
            ]);

        });

        geometry.uvsNeedUpdate = true;

    }

    function assignMaterials(geo, footprint, glazing, buildingHeight) {

        var material, face, faceIndex, prevNormal = {x: 10, y: 10}, materialList, currentMaterialIndex, wallTexture, currentWallIndex = 0;
        var numFloors = Math.round(buildingHeight/3.5);
        var wallP1, wallP2, wallLength, nextPointIndex;
        // load textures
        // var wallTexture = THREE.ImageUtils.loadTexture( "./static/assets/textures/dark-wall.jpeg"),
        //     groundTexture = THREE.ImageUtils.loadTexture( "./static/assets/textures/light-wall.jpg"),
        //     roofTexture = THREE.ImageUtils.loadTexture( "./static/assets/textures/red.jpg");

        materialList = [];
        // Add roofMaterial
        materialList.push(new THREE.MeshPhongMaterial( { side: THREE.DoubleSide, color: '#ff0000' }));
        currentMaterialIndex = 0;
        // Add groundMaterial
        materialList.push(new THREE.MeshPhongMaterial( { side: THREE.DoubleSide, color: '#999999' }));
        currentMaterialIndex++;

        for ( faceIndex in geo.faces ) {
            face = geo.faces[ faceIndex ];
            if (face.normal.z < 0.9 && face.normal.z > -0.9) { // normal could be 0.999.. for roof and floor

                if(face.normal.x !== prevNormal.x && face.normal.y !== prevNormal.y && currentWallIndex < footprint.length) {

                    nextPointIndex = (currentWallIndex + 1) % footprint.length;

                    wallP1 = new THREE.Vector2(footprint[currentWallIndex][0], footprint[currentWallIndex][1]);
                    wallP2 = new THREE.Vector2(footprint[nextPointIndex][0], footprint[nextPointIndex][1]); // assume duplicated point in footprint

                    wallLength = wallP1.distanceTo(wallP2);

                    wallTexture = new THREE.Texture(generateGlazingTexture(glazing[0][currentWallIndex]));
                    wallTexture.needsUpdate = true; // important
                    wallTexture.wrapS = wallTexture.wrapT = THREE.RepeatWrapping;
                    wallTexture.repeat.set(numFloors, wallLength);
                    materialList.push(new THREE.MeshPhongMaterial({
                        side: THREE.DoubleSide,
                        map: wallTexture
                    }));
                    currentWallIndex++;
                    currentMaterialIndex++;
                    prevNormal = face.normal;
                }

                face.materialIndex = currentMaterialIndex;

            } else if(face.normal.z === -1) {
                face.materialIndex = 1;
            } else {
                face.materialIndex = 0;
            }
        }

        // material combination
        material = new THREE.MeshFaceMaterial(materialList);

        return material;

    }

    function generateGlazingTexture(glazing) {

        glazing = glazing || 0;

        var size = 256;
        var width = size * glazing / 100;
        var start = Math.round((size - width) * 0.25);

        // create canvas
        var canvas = document.createElement( 'canvas' );
        canvas.width = size;
        canvas.height = size;

        // get context
        var context = canvas.getContext( '2d' );

        context.fillStyle = "grey";
        context.fillRect(0, 0, size, size);
        context.fillStyle = 'blue';
        context.fillRect(start, start, width, width);

        return canvas;

    }


    function getCentroid(arr) {
        var twoTimesSignedArea = 0;
        var cxTimes6SignedArea = 0;
        var cyTimes6SignedArea = 0;

        var length = arr.length;

        var x = function (i) { return arr[i % length][0]; };
        var y = function (i) { return arr[i % length][1]; };

        for ( var i = 0; i < arr.length; i++) {
            var twoSA = x(i)*y(i+1) - x(i+1)*y(i);
            twoTimesSignedArea += twoSA;
            cxTimes6SignedArea += (x(i) + x(i+1)) * twoSA;
            cyTimes6SignedArea += (y(i) + y(i+1)) * twoSA;
        }
        var sixSignedArea = 3 * twoTimesSignedArea;
        return [ cxTimes6SignedArea / sixSignedArea, cyTimes6SignedArea / sixSignedArea];
    }

    function polygonArea(points) {
        var area = 0, i, j;
        for (i = 0; i < points.length; i++) {
            j = (i + 1) % points.length;
            area += points[i][0] * points[j][1];
            area -= points[j][0] * points[i][1];
        }
        return area / 2;
    }

    function getWalls(geo) {
        var face, faceIndex, prevNormal, wall, wallIndex, wallPoints = [], walls = [];
        console.log(geo);
        for ( faceIndex in geo.faces ) {
            face = geo.faces[ faceIndex ];
            if(face.normal.z === 0) {
                if(!normalEquals(face.normal, prevNormal)) {
                    prevNormal = face.normal;
                    wallPoints.push([]);
                }
                wallPoints[wallPoints.length-1].push(geo.vertices[face.a]);
                wallPoints[wallPoints.length-1].push(geo.vertices[face.b]);
                wallPoints[wallPoints.length-1].push(geo.vertices[face.c]);
            }

        }

        for (wallIndex = 0; wallIndex < wallPoints.length; wallIndex++) {
            wall = wallPoints[wallIndex];
            walls.push(new THREE.Box3().setFromPoints(wall));
        }
        return walls;
    }

    function normalEquals(n1, n2) {
        if(!n1 || !n2) {
            return false;
        }
        return (Math.round(n1.x*100)/100) === (Math.round(n2.x*100)/100) &&
            (Math.round(n1.y*100)/100) === (Math.round(n2.y*100)/100) &&
            (Math.round(n1.z*100)/100) === (Math.round(n2.z*100)/100);
    }

    function getUrlParameter(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    }

    function createNewBuilding() {
        existingBuildingData = {
            buildingId: buildingId,
            userId: 'testUser',
            geoJson: {
                geometry: {
                    type:"Polygon",
                    coordinates:[[[4.419819116592407,51.215448764543524],[4.419819116592407,51.215408441676914],[4.41926121711731,51.21529419336308],[4.41926121711731,51.215139621663695],[4.419143199920654,51.21511273957604],[4.419143199920654,51.215011931607584],[4.419958591461182,51.21513290114326],[4.420012235641479,51.2150656958849],[4.420216083526611,51.21507241641516],[4.420194625854492,51.21514634218317],[4.420098066329956,51.21514634218317],[4.41999077796936,51.215307634355895],[4.4199371337890625,51.215287472865214],[4.419883489608765,51.215408441676914],[4.419947862625122,51.21542188263637],[4.4198620319366455,51.21552268970725],[4.420044422149658,51.21558989429855],[4.420430660247803,51.21487752063965],[4.419572353363037,51.21476327100837],[4.419529438018799,51.21487080008094],[4.419357776641846,51.21486407952126],[4.419368505477905,51.21476327100837],[4.418896436691284,51.214736388701],[4.4187891483306885,51.21522698834014],[4.419025182723999,51.21525387036108],[4.418982267379761,51.21532107534476],[4.419819116592407,51.215448764543524]]]},
                properties: {
                    glazing: [[40, 60, 80]],
                    height: 40
                },
                type: "Feature"
            }
        };

        return existingBuildingData;
    }

});
