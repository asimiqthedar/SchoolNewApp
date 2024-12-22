/*============================================================
 # Theme Name: Godrej 
 # Author: Sunil UI Developer
 # Version: 1.0
============================================================*/
// feesChart JS here

  var ctx = document.getElementById('feesChart').getContext('2d');
  var feesChart = new Chart(ctx, {
    type: 'pie',
    data: {
      labels: ['Fees Paid', 'Fees Pending'],
      datasets: [{
        label: 'Fees Status',
        data: [70, 30], // Data values for the chart
        backgroundColor: [
          '#4473c5', // Color for Fees Paid
          '#ed7d31' // Color for Fees Pending
        ],
        borderColor: [
          '#4473c5', 
          '#ed7d31'
        ],
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'bottom', // Position of the legend
        },
        tooltip: {
          callbacks: {
            label: function(tooltipItem) {
              let label = tooltipItem.label || '';
              let value = tooltipItem.raw;
              let total = tooltipItem.dataset.data.reduce((acc, val) => acc + val, 0);
              let percentage = ((value / total) * 100).toFixed(2);
              return label + ': ' + percentage + '%';
            }
          }
        },
        datalabels: {
          color: 'white', // Text color
          formatter: function(value, context) {
            let total = context.chart.data.datasets[0].data.reduce((acc, val) => acc + val, 0);
            let percentage = ((value / total) * 100).toFixed(2);
            return percentage + '%'; // Show percentage inside each slice
          },
          font: {
            size: 14, // Size of the text
            weight: 'bold'
          }
        }
      }
    },
    plugins: [ChartDataLabels]
  });

// feesTrendChart js here
const ctxFeesTrendChart = document.getElementById('feesTrendChart').getContext('2d');

    // Data for Fees Paid and Fees Pending over time
    const feesTrendData = {
      labels: ['Jan-23', 'Feb-23', 'Mar-23',], // X-axis labels (months)
      datasets: [
        {
          label: 'Fees Paid',
          data: [10, 11, 12, ], // Fees Paid data for each month
          backgroundColor: '#4473c5', // Blue color for Fees Paid
          borderWidth: 1,
          barThickness: 30 // Bar width
        },
        {
          label: 'Fees Pending',
          data: [5, 4, 3,], // Fees Pending data for each month
          backgroundColor: '#ed7d31', // Orange color for Fees Pending
          borderWidth: 1,
          barThickness: 30 // Bar width
        }
      ]
    };

    // Configuration for the stacked bar chart
    const feesTrendConfig = {
      type: 'bar',
      data: feesTrendData,
      options: {
        scales: {
          x: {
            stacked: true,
            position: 'bottom',
            title: {
              display: true,
              text: 'Months' // X-axis label
            }
          },
          y: {
            stacked: true,
            beginAtZero: true,

            min: 0, // Minimum value on the y-axis
            max: 15 // Maximum value on the y-axis (adjust this as needed)
          }
        },
        plugins: {
          legend: {
            position: 'bottom', // Position the dataset labels (legend) at the bottom
            labels: {
              boxWidth: 20, // Size of the colored box in the legend
              padding: 15 // Padding around the legend text
            }
          }
        }
      }
    };
    // Create the stacked bar chart
    const feesTrendChart = new Chart(ctxFeesTrendChart, feesTrendConfig);

// feesBarChart js here
const feesBarChartCtx = document.getElementById('feesBarChart').getContext('2d'); // Unique variable name
const feesBarChartData = {
    labels: ['2022', '2023', '2023', '2024',],
    datasets: [
        {
            label: 'Fees Paid',
            data: [10, 5, 15, 20,],
            backgroundColor: '#3f63b7',
            borderColor: '#3f63b7',
            borderWidth: 1,
            barThickness: 30,
        },
        {
            label: 'Fees Pending',
            data: [16, 14, 8, 12,],
            backgroundColor: '#dc7936',
            borderColor: '#dc7936',
            borderWidth: 1,
            barThickness: 30,
        },

    ]
};

// Create chart instance
let feesBarChart = new Chart(feesBarChartCtx, {
    type: 'bar',
    data: feesBarChartData,
    options: {
        scales: {
            y: {
                beginAtZero: true,
                min: 0,
                max: 20,
            },

        },
        plugins: {
            legend: {
                position: 'bottom',
                labels: {
                    boxWidth: 20,
                    padding: 15,
                }
            }
        }
    }
});