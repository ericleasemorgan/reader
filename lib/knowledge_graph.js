// knowledge_graph.js - given a JSON file of a specific shape, output a forced-directed graph
// written by Team JAMS (Aarushi Bisht, Cheng Jial, Mel Mashiku, and Shivam Rastogi as a part of the PEARC '19 Hack-a-thon

// tweaked by Eric Lease Morgan <emorgan@nd.edu>
// August 7, 2019 - first documentation


var width = 1100,
    height = 550,
    radius = 10,
    border = 1;

var bordercolor = 'black';

var color = d3.scaleOrdinal(d3.schemeCategory20);
var transform = d3.zoomIdentity;;

var simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id(function(d) {
        return d.id;
    }))
    .force("charge", d3.forceManyBody())
    .force("center", d3.forceCenter(width / 2, height / 2));


var svg = d3.select("#diagram")
    .append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("border", border);

var borderPath = svg.append("rect")
    .attr("x", 0)
    .attr("y", 0)
    .attr("height", height)
    .attr("width", width)
    .style("stroke", bordercolor)
    .style("fill", "none")
    .style("stroke-width", border);

var zoom = d3.zoom()
    .scaleExtent([1 / 4, 8])
    .on("zoom", zoomed);
svg.call(zoom)

d3.json("./etc/" + filename, function(error, graph) {
    if (error) throw error;
    console.log(console.log(JSON.stringify(graph)))
    console.log(graph.links.length)
    console.log(typeof(graph.links))

    var dict = {};

    addNodeCounts(graph, dict);
    console.log(console.log(JSON.stringify(graph)))
    var link = svg.append("g")
        .attr("class", "links")
        .selectAll("line")
        .data(graph.links)
        .enter().append("line")
        .attr("stroke-width", function(d) {
            return Math.sqrt(d.value);
        });


    link.append("title")
        .text("testing");


    var node = svg.append("g")
        .attr("class", "nodes")
        .selectAll("g")
        .data(graph.nodes)
        .enter().append("g")

    var circles = node.append("circle")
        .attr("r", function(d) {
            return d.count;
        })
        .attr("fill", function(d) {
            return color(Math.round(d.count));
        })
        .call(d3.drag()
            .on("start", dragstarted)
            .on("drag", dragged)
            .on("end", dragended));

    var lables = node.append("text")
        .text(function(d) {
            return d.id;
        })
        .attr('x', 6)
        .attr('y', 3);

    node.append("title")
        .text(function(d) {
            return d.id;
        });

    simulation
        .nodes(graph.nodes)
        .on("tick", ticked);

    simulation.force("link")
        .links(graph.links);

    function ticked() {
        link
            .attr("x1", function(d) {
                return d.source.x;
            })
            .attr("y1", function(d) {
                return d.source.y;
            })
            .attr("x2", function(d) {
                return d.target.x;
            })
            .attr("y2", function(d) {
                return d.target.y;
            });

        node
            .attr("transform", function(d) {
                return "translate(" + d.x + "," + d.y + ")";
            });
        node.attr("cx", function(d) {
                return d.x = Math.max(radius, Math.min(width - radius, d.x));
            })
            .attr("cy", function(d) {
                return d.y = Math.max(radius, Math.min(height - radius, d.y));
            });


    }
});

d3.select('#zoom_in').on('click', function() {
    // Smooth zooming
    zoom.scaleBy(svg.transition().duration(750), 1.1);
});

d3.select('#zoom_out').on('click', function() {
    // Ordinal zooming
    zoom.scaleBy(svg.transition().duration(750), 1 / 1.1);
});

function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
}

function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
}

function dragended(d) {
    if (!d3.event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
}

function zoomed() {
    svg.attr("transform", d3.event.transform);
}

function addNodeCounts(graph, dict) {
    //Add count of each node
    if(graph.links.length > 1000){
      normalize_size = Math.ceil(graph.links.length/1000)
    }
    else{
      normalize_size = 1
    }

    for (var i = 0; i < graph.links.length; i++) {

        //console.log(graph.links[i].target)
        target = graph.links[i].target
        source = graph.links[i].source
        if (target in dict) {
            dict[target] += 1
        } else {
            dict[target] = 1
        }
        if (source in dict) {
            dict[source] += 1
        } else {
            dict[source] = 1
        }
    }
    console.log(normalize_size)

    for (var i = 0; i < graph.nodes.length; i++) {
        node = graph.nodes[i].id
        if (node in dict) {
            graph.nodes[i]["count"] = dict[node]/normalize_size + 2
        } else {
            graph.nodes[i]["count"] = 2
        }
    }
}
