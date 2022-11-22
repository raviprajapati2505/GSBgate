const { ChartJSNodeCanvas } = require("chartjs-node-canvas");
const express = require("express");
const bodyParser = require("body-parser");
const app = express();

app.use(bodyParser.json());

// The app accepts POST calls in the following format: /600x600.png
// The request headers should contain "Content-Type: application/json"
// The request body should contain the JSON formatted chart.js config

// Start the app
app.listen(8082, function () {
  console.log("GSAS chart generator app listening on port 8082!");
});

// Creates a chart.js graph and hands it to the HTTP response
// function createChartImage(config, width, height, response) {
const mkChart = async (configs, width, height) => {
  const canvasRenderService = new ChartJSNodeCanvas({
    width: Number(width),
    height: Number(height),
    plugins: {
        requireLegacy: ['chartjs-plugin-datalabels']
    }
  });
  return await canvasRenderService.renderToBuffer(configs);
};

app.post('/:width(\\d+)x:height(\\d+).png', async function (request, response) {
	// Create the chart image and send the image as HTTP response
    var image = await mkChart(request.body, request.params.width, request.params.height, response);
    response.type("image/png");
    response.send(image);
});
