$(function () {
    $('.score-graph').each(function () {
        score_graph(this, $(this).data('show-legend'),  $(this).data('show-x-axis'), $(this).data('width'), $(this).data('height'), $(this).data('min'), $(this).data('max'), $(this).data('maxAttainable'), $(this).data('targeted'), $(this).data('submitted'));
    });
});

function score_graph($element, showLegend, showXaxis, width, height, min, max, maxAttainable, targeted, submitted) {
    if (!showXaxis) {
        height -= 18;
    }
    var margin = {top: (showXaxis ? 18 : 0), right: 130, bottom: 0, left: 10},
        graph_width = width - margin.left - margin.right,
        graph_height = height - margin.top - margin.bottom,
        data = [{class: 'progress-bar-max', value: maxAttainable}, {class: 'progress-bar-targeted', value: targeted}, {class: 'progress-bar-submitted', value: submitted}];

    var x = d3.scale.linear()
                .domain([min, max])
                .range([0, graph_width]);
    var y = d3.scale.ordinal()
                .domain(data.map(function(d) {
                    return d.class;
                }))
                .rangeRoundBands([0, graph_height], .1);

    var xAxis = d3.svg.axis()
                .scale(x)
                .orient("top")
                .ticks(5);

    var svg = d3.select($element)
        .append('svg')
            .attr('width', width)
            .attr('height', height)
        .append('g')
            .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    var bars = svg.selectAll('.bar')
                    .data(data)
                .enter().append('g')
                    .attr('class', 'progress-bar');

    bars.append('rect')
        .attr('class', function(d) {
            //return d.value < 0 ? 'bar negative' : 'bar positive';
            return d.class;
        })
        .attr('x', function(d) {
            return x(Math.min(0, d.value));
        })
        .attr('y', function(d) {
            return y(d.class);
        })
        .attr('width', function(d) {
            return Math.abs(x(d.value) - x(0));
        })
        .attr('height', y.rangeBand());

    bars.append('text')
        .text(function(d) {
            return d.value;
        })
        .attr('x', function(d) {
            return x(d.value);
        })
        .attr('y', function(d) {
            return y(d.class) + y.rangeBand() / 2;
        })
        .attr('dx', function(d) {
            return d.value < 0 ? '-.3em' : '.3em';
        })
        .attr('text-anchor', function(d) {
            return d.value < 0 ? 'end' : 'start';
        });

    if (showXaxis == true) {
        svg.append('g')
            .attr('class', 'x axis')
            .call(xAxis);
    }

    svg.append('g')
            .attr('class', 'y axis')
        .append('line')
            .attr('x1', x(0))
            .attr('x2', x(0))
            .attr('y2', graph_height);

    if (showLegend == true) {
        var legend = svg.selectAll('.legend')
                .data([{class: 'progress-bar-max', value: 'Max. Attainable'}, {class: 'progress-bar-targeted', value: 'Targeted'}, {class: 'progress-bar-submitted', value: 'Submitted'}])
            .enter().append('g')
                .attr('class', 'legend')
                .attr('transform', function (d, i) {
                    return 'translate(0,' + i * 10 + ')';
                });

        legend.append('rect')
            .attr('class', function (d) {
                return d.class;
            })
            .attr('x', width - 100)
            .attr('width', 9)
            .attr('height', 9);

        legend.append('text')
            .attr('x', width - 90)
            .attr('y', 9)
            .text(function (d) {
                return d.value;
            });
    }

}