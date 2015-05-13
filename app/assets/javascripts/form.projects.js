$(function() {
    // Initialize wizard
    var wizard = $('#certification-path-wizard').steps({
        headerTag: 'h1',
        bodyTag: 'section',
        transitionEffect: "slideLeft",
        stepsOrientation: "vertical",
        startIndex: 3,
        forceMoveForward: true,
        enableKeyNavigation: false,
        enablePagination: false
    });
});
