import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'
import { getRelativePosition } from 'chart.js/helpers';
import {LineController} from 'chart.js'

class ToolTipLine extends LineController {
  draw(ease) {
    super.draw(ease)
    if (this.chart.tooltip._active && this.chart.tooltip._active.length) {
      var activePoint = this.chart.tooltip._active[0],
      ctx = this.chart.ctx,
      x = activePoint.element.x,
      topY = this.chart.chartArea.top,
      bottomY = this.chart.chartArea.bottom;
      var value = this.chart.tooltip.title[0]


      // draw line
      ctx.save();
      ctx.beginPath();
      ctx.moveTo(x, topY);
      ctx.lineTo(x, bottomY);
      ctx.lineWidth = 1.5;
      ctx.strokeStyle = '#CCC';
      ctx.stroke();
      ctx.restore();
    }
  }
}

export default class extends Controller {
  static targets = [ "balancesChart", "balanceValue", "cashflowChart"]
  static values = {
    currency: String,
    balance: String,
    bankAccountId: Number,
  }

  initAnimation(length=2) {
    const totalDuration = 500;
    const delayBetweenPoints = totalDuration / 5;
    const previousY = (ctx) => ctx.index === 0 ? ctx.chart.scales.y.getPixelForValue(100) : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1].getProps(['y'], true).y;
    const animation = {
      x: {
        type: 'number',
        easing: 'linear',
        duration: delayBetweenPoints,
        from: NaN, // the point is initially skipped
        delay(ctx) {
          if (ctx.type !== 'data' || ctx.xStarted) {
            return 0;
          }
          ctx.xStarted = true;
          return ctx.index * delayBetweenPoints;
        }
      },
      y: {
        type: 'number',
        easing: 'linear',
        duration: delayBetweenPoints,
        from: previousY,
        delay(ctx) {
          if (ctx.type !== 'data' || ctx.yStarted) {
            return 0;
          }
          ctx.yStarted = true;
          return ctx.index * delayBetweenPoints;
        }
      }
    };
    return animation;
  }

  generateExternalLineToolTip(chart, tooltip) {
    let tooltipEl = chart.canvas.parentNode.querySelector('div');
    const currency = this.currencyValue;
    if (!tooltipEl) {
      tooltipEl = document.createElement('div');
      tooltipEl.style.position = 'absolute',
      tooltipEl.style.transition = 'all .1s ease';
      tooltipEl.style.backgroundColor = '#CCC';
      tooltipEl.style.color = '#555';
      tooltipEl.style.fontSize = '12px';
      tooltipEl.style.padding = '5px';
      tooltipEl.style.borderRadius = '5px';
      chart.canvas.parentNode.appendChild(tooltipEl);
    }
    const defaultBalance = this.balanceValue;
    // Hide if no tooltip
    if (tooltip.opacity === 0) {
      tooltipEl.style.opacity = 0;
      document.getElementById('balance-value').innerHTML = defaultBalance
      return;
    }

    // Set Text
    if (tooltip.body) {
      const label = tooltip.title;
      tooltipEl.innerHTML = label;
      const dataY = tooltip.dataPoints[0].raw['y'];
      const value = Number.parseFloat(dataY).toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      document.getElementById('balance-value').innerHTML = value;
    }

    const {offsetLeft: positionX, offsetTop: positionY} = chart.canvas;

    // Display, position, and set styles for font
    tooltipEl.style.opacity = 1;
    tooltipEl.style.left = (positionX + tooltip.caretX - 10) + 'px';
    tooltipEl.style.top = (positionY + chart.chartArea.top - 30) + 'px';
  }

  initConfig(type, dataset, externalTooltipHandler) {
    const animation = this.initAnimation()
    const currency = this.currencyValue
    const config = {
      type: type,
      backgroundColor: '#EEE',
      data: {
        datasets: dataset,
      },
      options: {
        animation,
        // onHover: (e) => {
//           const chart = e.chart
//           const canvasPosition = getRelativePosition(e, e.chart);
//           const dataY = chart.scales.y.getValueForPixel(canvasPosition.y);
//           const value = Number.parseFloat(dataY).toLocaleString(
//             undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
//           )
//           document.getElementById('balance-value').innerHTML = value
//         },
        interaction: {
          intersect: false,
        },
        plugins: {
          legend: false,
          tooltip: {
            enabled: false,
            intersect: false,
            position: 'nearest',
            external: externalTooltipHandler
          },
        },
        scales: {
          x: {
            grid: {
              borderWidth: 0,
              drawTicks: false,
              lineWidth: 0,
              display: false,
            },
            ticks: {
              display: false,
            },
          },
          y: {
            type: 'linear',
            grid: {
              borderWidth: 0,
              drawTicks: false,
              lineWidth: 0,
              display: false,
            },
            ticks: {
              display: false,
            }
          }
        }
      }
    };
    return config;
  }

  balancesChartTargetConnected(element) {
    console.debug("Balance Chart connected.")
    fetch(`/bank_accounts/${this.bankAccountIdValue}/balances.json`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data_json => {
      const balanceTrend = Object.entries(data_json['balances']).map(function(item) {
        return { x: new Date(item[1]['updated_at']).toDateString(), y: item[1]['current'] }
      });
      console.debug('Success:', balanceTrend);
      ToolTipLine.id = 'ToolTipLine';
      ToolTipLine.defaults = LineController.defaults;
      const defaultBalance = this.balanceValue;

      const externalTooltipHandler = (context) => {
        const {chart, tooltip} = context;
        this.generateExternalLineToolTip(chart, tooltip);
      };

      Chart.register(ToolTipLine);
      const dataset = [{
        borderColor: 'rgb(114 107 250)',
        backgroundColor: '#EEE',
        borderWidth: 3,
        radius: 0,
        data: balanceTrend,
        fill: true,
        pointStyle: 'circle',
        pointRadius: 3,
      }];
      const config = this.initConfig('ToolTipLine', dataset, externalTooltipHandler)

      const myChart = new Chart(
        document.getElementById('balances-chart'),
        config,
      );
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }

  makeCashflowChart(type, chart_dataset) {
    console.debug("makeCashflowChart")
    ToolTipLine.id = 'ToolTipLine';
    ToolTipLine.defaults = LineController.defaults;
    const defaultBalance = this.balanceValue;

    const externalTooltipHandler = (context) => {
      const {chart, tooltip} = context;
      this.generateExternalLineToolTip(chart, tooltip);
    };

    Chart.register(ToolTipLine);
    const config = this.initConfig('ToolTipLine', chart_dataset, externalTooltipHandler)
    const myChart = new Chart(
      document.getElementById('cashflow-chart'),
      config,
    );
  }

  cashflowChartTargetConnected(element) {
    console.debug("Cashflow Chart connected.")
    fetch("/accounts/cashflow_trend", {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data_json => {
      const assetsTrend = Object.entries(data_json['assets_trend']).map(function(item) {
        return { x: new Date(item[0]).toDateString(), y: item[1] }
      });
      const liabilitiesTrend = Object.entries(data_json['liabilities_trend']).map(function(item) {
        return { x: new Date(item[0]).toDateString(), y: item[1] }
      });
      const dataset = [
        {
          borderColor: 'rgb(114 107 250)',
          backgroundColor: '#EEE',
          borderWidth: 3,
          radius: 0,
          data: assetsTrend,
        },
        {
          borderColor: '#AAA',
          backgroundColor: '#EEE',
          borderWidth: 3,
          radius: 0,
          data: liabilitiesTrend,
        },

      ]
      this.makeCashflowChart('ToolTipLine', dataset)
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }
}