import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'
import { getRelativePosition } from 'chart.js/helpers';
import {BarController} from 'chart.js'

const MONTHS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
]

class ToolTipLine extends BarController {
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

  intlFormat(num, currency = null) {
    if (currency) {
      return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency }).format(num);
    } else {
      return new Intl.NumberFormat().format(Math.round(num*10)/10);
    }
  }

  makeFriendly(num) {
    let absNum = Math.abs(num), value = ''
    if(absNum >= 1000000) {
      value = this.intlFormat(absNum/1000000)+'M'
      return num < 0 ? '-$' + value : '$' + value
    } else if(absNum >= 1000) {
      value = this.intlFormat(absNum/1000)+'k'
      return num < 0 ? '-$' + value : '$' + value
    } else {
      value = this.intlFormat(absNum)
      return num < 0 ? '-$' + value : '$' + value
    }
  }

  formatDate(date) {
    let month = MONTHS[date.getMonth()]
    let year = date.getFullYear()
    return `${month} ${year}`
  }

  initAnimation(delayBetweenPoints=2) {
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

  generateCashflowToolTip(chart, tooltip) {
    let tooltipEl = chart.canvas.parentNode.querySelector('div');
    const currency = this.currencyValue || 'USD';
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
      // document.getElementById('balance-value').innerHTML = defaultBalance
      return;
    }

    // Set Text
    if (tooltip.body) {
      const label = tooltip.title;
      tooltipEl.innerHTML = label;
      const assetValue = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[1]).toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      const liabilityValue = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[0]).toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      document.getElementById('asset-value').innerHTML = assetValue;
      document.getElementById('liability-value').innerHTML = liabilityValue;
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
    const self = this
    const minValue = Math.min(0, Math.min(...dataset[0].data.map(item => item.y)))

    const config = {
      type: type,
      backgroundColor: '#EEE',
      data: {
        datasets: dataset,
      },
      options: {
        animation,
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
              borderWidth: 1,
              drawTicks: true,
              lineWidth: 0.5,
              display: true,
            },
            ticks: {
              display: true,
              callback: function(value, index, values) {
                const label = this.getLabelForValue(value);
                return self.formatDate(new Date(label));
              },
              maxRotation: 0,
            },
            stacked: true,
          },
          y: {
            type: 'linear',
            min: minValue,
            maxTicksLimit: 6,
            count: 6,
            grid: {
              borderWidth: 1,
              drawTicks: true,
              lineWidth: 0.5,
              display: true,
            },
            ticks: {
              display: true,
              callback: function(value, index, values) {
                return self.makeFriendly(value);
              },
            },
            stacked: true,
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
      ToolTipLine.defaults = BarController.defaults;
      const defaultBalance = this.balanceValue;

      const externalTooltipHandler = (context) => {
        const {chart, tooltip} = context;
        this.generateExternalLineToolTip(chart, tooltip);
      };

      Chart.register(ToolTipLine);
      const dataset = [{
        borderColor: 'rgb(114 107 250)',
        backgroundColor: 'rgb(114 107 250)',
        hoverBackgroundColor: 'rgb(114 107 250)',
        borderWidth: 1,
        data: balanceTrend,
        fill: true,
        pointStyle: 'circle',
        categoryPercentage: 1.0,
        barPercentage: 1.0,
        maxBarThickness: 50,
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
    ToolTipLine.id = 'ToolTipLine';
    ToolTipLine.defaults = BarController.defaults;
    const defaultBalance = this.balanceValue;

    const externalTooltipHandler = (context) => {
      const {chart, tooltip} = context;
      this.generateCashflowToolTip(chart, tooltip);
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
          borderColor: '#f38d79',
          backgroundColor:      '#f38d79',
          hoverBackgroundColor: '#f38d79',
          data: liabilitiesTrend,
          categoryPercentage: 0.9,
          barPercentage:      0.9,
          maxBarThickness: 50,
          fill: true,
        },
        {
          borderColor:          '#FFF',
          backgroundColor:      '#7069fab5',
          hoverBackgroundColor: '#7069fab5',
          data: assetsTrend,
          categoryPercentage: 0.90,
          barPercentage:      0.90,
          maxBarThickness:    50,
          fill: true,
        },
      ]
      this.makeCashflowChart('ToolTipLine', dataset)
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }
}