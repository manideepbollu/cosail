var startMarker;
var endMarker;
var map;
var routePath;

function initMap() {
    map = new google.maps.Map(document.getElementById('new-itinerary-map'), {
        center: {lat: -34.397, lng: 150.644},
        zoom: 5,
        maxZoom: 10,
        minZoom: 2
    });
}

function setStartMarker(lat, lon, label) {
    var latLng = {lat: lat, lng: lon};
    map.setCenter(latLng);
    if (startMarker != null)
        startMarker.setMap(null);
    startMarker = new google.maps.Marker({
        position: latLng,
        map: map,
        title: label,
        animation: google.maps.Animation.DROP
    });
    if (routePath != null)
        routePath.setMap(null);
    adjustBoundaries(null);
}

function setEndMarker(lat, lon, label) {
    var latLng = {lat: lat, lng: lon};
    map.setCenter(latLng);
    if (endMarker != null)
        endMarker.setMap(null);
    endMarker = new google.maps.Marker({
        position: latLng,
        map: map,
        title: label,
        animation: google.maps.Animation.DROP
    });
    if (routePath != null)
        routePath.setMap(null);
    adjustBoundaries(null);
}

function adjustBoundaries(data) {
    var bounds = new google.maps.LatLngBounds();
    if (startMarker != null)
        bounds.extend(startMarker.getPosition());
    if (endMarker != null)
        bounds.extend(endMarker.getPosition());
    if (data != null){
        var points = data.getPath().getArray();
        for (var n = 0; n < points.length ; n++)
            bounds.extend(points[n]);
    }
    map.fitBounds(bounds);
}

function drawRoute(data) {
    var routeCoordinates = data;
    routePath = new google.maps.Polyline({
        path: routeCoordinates,
        geodesic: true,
        strokeColor: '#FF0000',
        strokeOpacity: 1.0,
        strokeWeight: 2
    });
    routePath.setMap(map);
    adjustBoundaries(routePath);
    document.getElementById("itineraries-spinner").className = "hide";
    $("#incomplete-setup").addClass('hide');
    setDatainWizard2();
    $("#result").slideDown("slow", function () {
        // Animation completed
    });
}

function setDatainWizard2(){
    var encodedPath = google.maps.geometry.encoding.encodePath(routePath.getPath());
    $("input#itinerary_start_coords").val(startMarker.getPosition().toUrlValue());
    $("input#itinerary_end_coords").val(endMarker.getPosition().toUrlValue());
    $("input#itinerary_route_path").val(encodedPath);
    $('#itinerary-preview-image').attr('src', "http://maps.googleapis.com/maps/api/staticmap?size=640x360&scale=2&sensor=false&markers=color:green|label:B|"+ endMarker.getPosition().toUrlValue() +"&markers=color:green|label:A|"+ startMarker.getPosition().toUrlValue() +"&path=enc:"+ encodedPath);
    $('#itinerary-preview-from').html($("input#itinerary_start_address").val());
    $('#itinerary-preview-to').html($("input#itinerary_end_address").val());

}

$(document).ready(function() {

    $("#get-route").click(function () {
        var startPort = document.getElementById('itinerary_start_port_id').value;
        var endPort = document.getElementById('itinerary_end_port_id').value;
        if(startPort == '' || endPort == '')
            alert('Please choose Start and End addresses for your itinerary.')
        else{
            document.getElementById("itineraries-spinner").className = "";
            $.ajax({
                type: "GET",
                url: "/ports/route.json?fport=" + startPort + "&tport=" + endPort, // change to full path of file on server
                dataType: "json",
                success: function(data){
                    $("#distance").html(data.distance);
                    $("#duration").html(data.duration);
                    drawRoute(data.coords);
                },
                failure: function (data) {
                    console.log("XML File could not be found");
                }
            });
        }
    });

    $("#wizard-next-step-button").click(function () {
        var route = $("input#itinerary_route_path").val();
        if(route != '' && routePath != null) {
            $("#wizard-step-2-content").removeClass("hide");
            $("#wizard-prev-step-button").removeClass("hide");
            $("#new_itinerary_submit").removeClass("hide");
            $("#wizard-step-1-content").addClass("hide");
            $("#wizard-next-step-button").addClass("hide");
        }else
            $("#incomplete-setup").removeClass('hide');
    });

    $("#wizard-prev-step-button").click(function () {
        $("#wizard-step-2-content").addClass("hide");
        $("#wizard-prev-step-button").addClass("hide");
        $("#new_itinerary_submit").addClass("hide");
        $("#wizard-step-1-content").removeClass("hide");
        $("#wizard-next-step-button").removeClass("hide");
    });

    $('#search-form-advanced-link').click(function(){
        if ($('#toggle-tracker').val() === 'true')
            $('#toggle-tracker').val('false');
        else
            $('#toggle-tracker').val('true');
    });

    $("#itineraries-search").on("click",
        function validateForm() {
            var start = $("#itinerary_start_address").val();
            var end = $("#itinerary_end_address").val();
            if (start == '' && end == '') {
                alert('Please fill in your search criteria. At-least one entry is required to perform a search operation.');
                return false;
            } else {
                document.getElementById("itineraries-spinner").className = "";
                return true;
            }
        });

    // New lines start here

    var suggestArr = [];

    $.ajax({
        type: "GET",
        url: "/ports/suggest.json", // change to full path of file on server
        dataType: "json",
        success: function(data){
            for (var x in data) {
                var subData = data[x];
                suggestArr.push({
                    portId: subData.portId,
                    value: subData.value,
                    lat: subData.lat,
                    lon: subData.lon
                });
            }
        },
        complete: setupAC,
        failure: function (data) {
            console.log("XML File could not be found");
        }
    });

    function setupAC(){
        $("input#itinerary_start_address").autocomplete({
            source: suggestArr,
            minLength: 3,
            select: function (event, ui) {
                event.preventDefault();
                $("input#itinerary_start_port_id").val(ui.item.portId);
                $("input#itinerary_start_address").val(ui.item.value);
                $("#start_coords").html('Coords: ' + ui.item.lat + ', ' + ui.item.lon);
                suggestArr = [];
                setStartMarker(ui.item.lat, ui.item.lon, ui.item.value);
            }
        });

        $("input#itinerary_end_address").autocomplete({
            source: suggestArr,
            minLength: 3,
            select: function (event, ui) {
                event.preventDefault();
                $("input#itinerary_end_port_id").val(ui.item.portId);
                $("input#itinerary_end_address").val(ui.item.value);
                $("#end_coords").html('Coords: ' + ui.item.lat + ', ' + ui.item.lon);
                suggestArr = [];
                setEndMarker(ui.item.lat, ui.item.lon, ui.item.label);
            }
        });
    }

});

