if (typeof jQuery === "undefined") {
    throw new Error("jQuery plugins need to be before this file");
}

var options = {
    chart: {
        height: 300,
        type: 'area',
        stacked: true,
        toolbar: {
            show: false,
        },
        events: {
            selection: function (chart, e) {
                console.log(new Date(e.xaxis.min))
            }
        },
    },

    colors: ['#ff4560'],
    dataLabels: {
        enabled: false
    },

    series: [
        {
            name: 'Hours',
            data: generateDayWiseTimeSeries(new Date('02 Jan 2017 GMT').getTime(), 31, {
                min: 1,
                max: 10
            })
        }
    ],

    fill: {
        type: 'gradient',
        gradient: {
            opacityFrom: 0.6,
            opacityTo: 0.8,
        }
    },

    legend: {
        position: 'top',
        horizontalAlign: 'right',
        show: true,
    },
    xaxis: {
        type: 'datetime',
    },
    grid: {
        yaxis: {
            lines: {
                show: false,
            }
        },
        padding: {
            top: 20,
            right: 0,
            bottom: 0,
            left: 0
        },
    },
    stroke: {
        show: true,
        curve: 'smooth',
        width: 2,
    },
}
var chart = new ApexCharts(
    document.querySelector("#apex-stacked-area-month"),
    options
);
chart.render();
function generateDayWiseTimeSeries(baseval, count, yrange) {
    var i = 0;
    var series = [];
    while (i < count) {
        var x = baseval;
        var y = Math.floor(Math.random() * (yrange.max - yrange.min + 1)) + yrange.min;

        series.push([x, y]);
        baseval += 86400000;
        i++;
    }
    return series;
}

$(function () {

    "use strict";

    //**************//

    //**************//
    var options = {
        chart: {
            height: 180,
            type: 'radialBar',
        },
        colors: ['#ED5782'],
        plotOptions: {
            radialBar: {
                hollow: {
                    size: '70%',
                }
            },
        },
        series: [50],
        labels: ['Design'],
    }
    var chart = new ApexCharts(
        document.querySelector("#apex-circle-chart-one"),
        options
    );
    chart.render();

    //**************//
    var options = {
        chart: {
            height: 180,
            type: 'radialBar',
        },
        colors: ['#c9b8b8'],
        plotOptions: {
            radialBar: {
                hollow: {
                    size: '70%',
                }
            },
        },
        series: [80],
        labels: ['Devlopment'],
    }
    var chart = new ApexCharts(
        document.querySelector("#apex-circle-chart-two"),
        options
    );
    chart.render();
});



if (typeof jQuery === "undefined") {
    throw new Error("jQuery plugins need to be before this file");
}
$(document).ready(function () {
    var options = {
        chart: {
            height: 80,
            type: 'rangeBar',
            toolbar: {
                show: false,
            }
        },
        plotOptions: {
            bar: {
                horizontal: true,
            }
        },
        colors: ['#ff4560', '#f7c56b'],

        series: [{
            name: 'Joe',
            data: [{
                x: '',
                y: [new Date('2022-01-31').getTime(), new Date('2022-02-01').getTime()]
            }]
        }],
        yaxis: {
            min: new Date('2022-01-31').getTime(),
            max: new Date('2022-02-01').getTime()
        },
        xaxis: {
            type: 'datetime'
        },
        fill: {
            type: 'gradient',
            gradient: {
                shade: 'light',
                type: "vertical",
                shadeIntensity: 0.25,
                gradientToColors: undefined,
                inverseColors: true,
                opacityFrom: 1,
                opacityTo: 1,
                stops: [50, 0, 100, 100]
            }
        }
    }

    var chart = new ApexCharts(
        document.querySelector("#apex-timeline-two"),
        options
    );

    chart.render();
});
