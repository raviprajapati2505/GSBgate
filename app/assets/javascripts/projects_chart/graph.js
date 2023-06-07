var width = 500;
var height = 680;
var radius = width/6;

const chart = (projData, propName)=>{

  const formatting = (name, d)=>{
        if (Array.isArray(d)){
            return ({name, value: propName===""?d.length:d.reduce((a,b)=>a+b[propName],0)})  //children: d.map(p=>{return {name:p["Project ID"], value:p.cArea, children:[]}})})
        } else {
            let sorted =Object.keys(d).sort();
            return ({name, children:sorted.map(k=>formatting(k, d[k]))})
        } 
    }

    let formattedData = formatting("GSAS", projData)

    var root = partition(formattedData);
    root.each(d => d.current = d);

    //console.log(root.descendants().slice(1))

    var svg = d3.select("#chartDiv")
        .append("svg")
        .attr("viewBox", [0, 0, width, width])
        .style("font", "10px sans-serif");

    var g = svg.append("g")
        .attr("transform", `translate(${width / 2},${width / 2})`);

    var path = g.append("g")
        .selectAll("path")
        .data(root.descendants().slice(1))
        .join("path")
            .attr("fill", d => { while (d.depth > 1) d = d.parent; return color(d.data.name, d.parent.data); })
            .attr("fill-opacity", d => arcVisible(d.current) ? (d.children ? 0.6 : 0.4) : 0)
            .attr("pointer-events", d => arcVisible(d.current) ? "auto" : "none")
            .attr("d", d => arc(d.current));

    path.filter(d => d.children)
        .style("cursor", "pointer")
        .on("click", clicked);

    path.append("title")
        .text(d => `${d.ancestors().map(d => d.data.name).reverse().join("/")}\n${d.value.toString()}`);

    var label = g.append("g")
            .attr("pointer-events", "none")
            .attr("text-anchor", "middle")
            .style("user-select", "none")
        .selectAll("text")
        .data(root.descendants().slice(1))
        .join("text")
            .attr("dy", "0.35em")
            .attr("fill-opacity", d => +labelVisible(d.current))
            .attr("transform", d => labelTransform(d.current))
            .text(d => d.data.name.length>20?d.data.name.substring(0,18)+"...":d.data.name);

    var parent = g.append("circle")
        .datum(root)
        .attr("r", radius)
        .attr("fill", "none")
        .attr("pointer-events", "all")
        .on("click", clicked);

    function clicked(event, p) {
        parent.datum(p.parent || root);

        root.each(d => d.target = {
            x0: Math.max(0, Math.min(1, (d.x0 - p.x0) / (p.x1 - p.x0))) * 2 * Math.PI,
            x1: Math.max(0, Math.min(1, (d.x1 - p.x0) / (p.x1 - p.x0))) * 2 * Math.PI,
            y0: Math.max(0, d.y0 - p.depth),
            y1: Math.max(0, d.y1 - p.depth)
        });

        var t = g.transition().duration(750);

        // Transition the data on all arcs, even the ones that aren’t visible,
        // so that if this transition is interrupted, entering arcs will start
        // the next transition from the desired position.
        path.transition(t)
            .tween("data", d => {
                var i = d3.interpolate(d.current, d.target);
                return t => d.current = i(t);
            })
            .filter(function(d) {
            return +this.getAttribute("fill-opacity") || arcVisible(d.target);
            })
            .attr("fill-opacity", d => arcVisible(d.target) ? (d.children ? 0.6 : 0.4) : 0)
            .attr("pointer-events", d => arcVisible(d.target) ? "auto" : "none") 

            .attrTween("d", d => () => arc(d.current));

        label.filter(function(d) {
            return +this.getAttribute("fill-opacity") || labelVisible(d.target);
            }).transition(t)
            .attr("fill-opacity", d => +labelVisible(d.target))
            .attrTween("transform", d => () => labelTransform(d.current));
    }

    function arcVisible(d) {
        return d.y1 <= 3 && d.y0 >= 1 && d.x1 > d.x0;
    }

    function labelVisible(d) {
        return d.y1 <= 3 && d.y0 >= 1 && (d.y1 - d.y0) * (d.x1 - d.x0) > 0.03;
    }

    function labelTransform(d) {
        var x = (d.x0 + d.x1) / 2 * 180 / Math.PI;
        var y = (d.y0 + d.y1) / 2 * radius;
        return `rotate(${x - 90}) translate(${y},0) rotate(${x < 180 ? 0 : 180})`;
    }

}

const partition = data => {
    var root = d3.hierarchy(data)
        .sum(d => d.value);
        //.sort((a, b) => b.value - a.value);
    return d3.partition()
        .size([2 * Math.PI, root.height + 1])
      (root);
}

const color = (name, mainEl)=> {
    let hue = 360*(mainEl.children.findIndex(c=>c.name===name)+1)/mainEl.children.length
    //console.log(hue)
    return `hsl(${hue},50%,50%)`
    //console.log(data)
    //return d3.scaleOrdinal(d3.quantize(d3.interpolateRainbow, data.children.length + 1))
}

const arc = d3.arc()
    .startAngle(d => d.x0)
    .endAngle(d => d.x1)
    .padAngle(d => Math.min((d.x1 - d.x0) / 2, 0.005))
    .padRadius(radius * 1.5)
    .innerRadius(d => d.y0 * radius)
    .outerRadius(d => Math.max(d.y0 * radius, d.y1 * radius - 1))

    const chart2 = (projData, propName)=>{

    let total = 0;

    var formatting = (name, d)=>{
        if (Array.isArray(d)){
            let sum = propName===""?d.length:d.reduce((a,b)=>a+b[propName],0);
            total +=sum
            return ({name, value: sum })  //children: d.map(p=>{return {name:p["Project ID"], value:p.cArea, children:[]}})})
        } else {
            let sorted =Object.keys(d).sort();
            return ({name, children:sorted.map(k=>formatting(k, d[k]))})
        } 
    }

    let formattedData = formatting("GSAS", projData)

    var root = treemap(formattedData);
  
    var svg = d3.select("#chartDiv")
        .append("svg")
            .attr("viewBox", [0, 0, width, height])
            .style("font", "10px sans-serif");
  
    var shadow = "idk" //DOM.uid("shadow");
  
    svg.append("filter")
        .attr("id", shadow.id)
      .append("feDropShadow")
        .attr("flood-opacity", 0.3)
        .attr("dx", 0)
        .attr("stdDeviation", 3);
  
    var node = svg.selectAll("g")
      .data(d3.group(root, d => d.height))
      .join("g")
        .attr("filter", shadow)
      .selectAll("g")
      .data(d => d[1])
      .join("g")
        .attr("transform", d => `translate(${d.x0},${d.y0})`);
  
    node.append("title")
        .text(d => `${d.ancestors().reverse().map(d => d.data.name).join("/")}\n${d.value.toString()}`);
  
    node.append("rect")
        .attr("id", d => (d.nodeUid = "node") )// DOM.uid("node")).id)
        .attr("fill", d => color2(d.height))
        .attr("width", d => d.x1 - d.x0)
        .attr("height", d => d.y1 - d.y0);
  
    node.append("clipPath")
        .attr("id", d => (d.clipUid = "clip")) // DOM.uid("clip")).id)
      .append("use")
        .attr("xlink:href", d => d.nodeUid.href);
  
    node.append("text")
        .attr("clip-path", d => d.clipUid)
      .selectAll("tspan")
      .data(d => (d.value/total)<0.01?"":(d.data.name.length>30?d.data.name.substring(0,28)+"...":d.data.name).split(/(?=[A-Z][^A-Z])/g).concat(d.value.toLocaleString('en-US')))
      .join("tspan")
        .attr("fill-opacity", (d, i, nodes) => i === nodes.length - 1 ? 0.7 : null)
        .text(d => d);
  
    node.filter(d => d.children).selectAll("tspan")
        .attr("dx", 3)
        .attr("y", 13);
  
    node.filter(d => !d.children).selectAll("tspan")
        .attr("x", 3)
        .attr("y", (d, i, nodes) => `${(i === nodes.length - 1) * 0.3 + 1.1 + i * 0.9}em`);
  
    //return svg.node();
}

var name = d => d.ancestors().reverse().map(d => d.data.name).join("/")
var format = d3.format(",d")
var treemap = data => d3.treemap()
        .size([width, height])
        .paddingOuter(3)
        .paddingTop(19)
        .paddingInner(1)
        .round(true)
    (d3.hierarchy(data)
        .sum(d => d.value)
        .sort((a, b) => b.value - a.value))

var color2 = d3.scaleSequential([5, 0], t=>`hsl(173,43%,${100*(0.21+0.65*t)}%)`)