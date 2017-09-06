const chartjsNode = require('chartjs-node');
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

// The app accepts POST calls in the following format: /600x600.png
// The request headers should contain "Content-Type: application/json"
// The request body should contain the JSON formatted chart.js config
app.post('/:width(\\d+)x:height(\\d+).png', function (request, response) {
	// Create the chart image and send the image as HTTP response
  	createChartImage(request.body, request.params.width, request.params.height, response);
});

// Start the app
app.listen(8082, function () {
  console.log('GSAS chart generator app listening on port 8082!');
});

// Creates a chart.js graph and hands it to the HTTP response
function createChartImage(config, width, height, response) {
	var chartNode = new chartjsNode(width, height);
	
	return chartNode.drawChart(config)
	.then(() => {
	    // The chart is created

	    // Get the image as png buffer
	    return chartNode.getImageBuffer('image/png');
	})
	.then(imageBuffer => {
	    Array.isArray(imageBuffer) // => true

	    // Get the image as a stream
	    var imageStream = chartNode.getImageStream('image/png');

	    // Set some headers
		response.set('Content-Type', 'image/png');
		response.set('Content-Length', imageStream.length);

		// Clean up
		chartNode.destroy();

		// Send the image
		response.send(imageBuffer);
	});
}