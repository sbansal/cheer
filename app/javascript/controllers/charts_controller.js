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

CHART_BG_COLORS = [
  '#7069FA',
  '#f58973',
]

CHART_BORDER_COLORS = [
  '#7069FA',
  '#f58973',
]

TICK_FONT_SIZE = 12;

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
      ctx.save();
      ctx.beginPath();
      ctx.moveTo(x, topY);
      ctx.lineTo(x, bottomY);
      ctx.lineWidth = 1.5;
      ctx.strokeStyle = '#D9E2EC';
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
    defaultAssets: String,
    defaultLiabilities: String,
    defaultNetWorth: String,
    defaultIncome: String,
    defaultExpenses: String,
    defaultSavings: String,
    darkMode: Boolean,
    tickColor: String,
    period: String,
  }

  intlFormat(num, currency = null) {
    if (currency) {
      return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency }).format(num);
    } else {
      return new Intl.NumberFormat().format(Math.round(num*10)/10);
    }
  }

  // converts a date string like '2020-01-01 00:00:00 UTC' into a js Date object
  // return a date that is timezone independent
  convertDate = (jsonDateTime) => {
    let [year, month, date] = jsonDateTime.split(' ')[0].split('-')
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(date))
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
    const previousY = (ctx) => ctx.index === 0 ? ctx.chart.scales.y.getPixelForValue(100) : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1]?.getProps(['y'], true).y;
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

  updateDefaultValues = (chartType) => {
    if (chartType === 'balance' && document.getElementById('balance-value')) {
      document.getElementById('balance-value').innerHTML = this.balanceValue;
    } else if (chartType == 'cashflow') {
      if (document.getElementById('assets-value')) {
        document.getElementById('assets-value').innerHTML = this.defaultAssetsValue
      }
      if (document.getElementById('liabilities-value')) {
        document.getElementById('liabilities-value').innerHTML = this.defaultLiabilitiesValue
      }
      if (document.getElementById('net-worth-value')) {
        document.getElementById('net-worth-value').innerHTML = this.defaultNetWorthValue
      }
    } else if (chartType == 'incomeExpense') {
      if (document.getElementById('income-value')) {
        document.getElementById('income-value').innerHTML = this.defaultIncomeValue
      }
      if (document.getElementById('expenses-value')) {
        document.getElementById('expenses-value').innerHTML = this.defaultExpensesValue
      }
      if (document.getElementById('savings-value')) {
        document.getElementById('savings-value').innerHTML = this.defaultSavingsValue
      }
    }
  };

  updateToolTipValues = (chartType, tooltip) => {
    const currency = this.currencyValue || 'USD';
    if (chartType === 'balance' && document.getElementById('balance-value')) {
      const dataY = tooltip.dataPoints[0].raw['y'];
      const value = Number.parseFloat(dataY).toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      document.getElementById('balance-value').innerHTML = value;
    } else if (chartType == 'cashflow') {
      const assetsNumber = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[0])
      const liabilitiesNumber = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[1])
      const netWorthNumber =   assetsNumber - liabilitiesNumber
      const assetValue = assetsNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      const liabilityValue = liabilitiesNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      const netWorthValue = netWorthNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      document.getElementById('assets-value').innerHTML = assetValue;
      document.getElementById('liabilities-value').innerHTML = liabilityValue;
      document.getElementById('net-worth-value').innerHTML = netWorthValue;
    } else if (chartType == 'incomeExpense') {
      const incomeNumber = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[0])
      const expensesNumber = Number.parseFloat(tooltip.dataPoints[0].parsed._stacks.y[1])
      const savingsNumber =   incomeNumber - expensesNumber
      const incomeValue = incomeNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      const expensesValue = expensesNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      const savingsValue = savingsNumber.toLocaleString(
        undefined, { maximumFractionDigits: 2, style: 'currency', currency: currency }
      )
      document.getElementById('income-value').innerHTML = incomeValue;
      document.getElementById('expenses-value').innerHTML = expensesValue;
      document.getElementById('savings-value').innerHTML = savingsValue;
    }
  };

  generateExternalLineToolTip = (chart, tooltip, chartType) => {
    let tooltipEl = chart.canvas.parentNode.querySelector('div');
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
    if (tooltip.opacity === 0) {
      tooltipEl.style.opacity = 0;
      this.updateDefaultValues(chartType)
      return;
    }
    if (tooltip.body) {
      const label = tooltip.title;
      tooltipEl.innerHTML = label;
      this.updateToolTipValues(chartType, tooltip)
    }
    const {offsetLeft: positionX, offsetTop: positionY} = chart.canvas;
    tooltipEl.style.opacity = 1;
    tooltipEl.style.left = (positionX + tooltip.caretX - 10) + 'px';
    tooltipEl.style.top = (positionY + chart.chartArea.top - 30) + 'px';
  }

  initConfig(type, dataset, externalTooltipHandler, showLegend) {
    const animation = this.initAnimation()
    const self = this
    const minValue = Math.min(0, Math.min(...dataset[0].data.map(item => item.y)))

    Chart.defaults.font.family = "-apple-system,BlinkMacSystemFont,'Segoe UI','Roboto','Helvetica Neue','Ubuntu',sans-serif";
    Chart.defaults.plugins.legend.align = 'end';
    const config = {
      type: type,
      data: {
        datasets: dataset,
      },
      options: {
        animation,
        interaction: {
          intersect: false,
        },
        plugins: {
          legend: {
            display: showLegend,
            labels: {
              usePointStyle: true,
              boxWidth: 6
            }
          },
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
              lineWidth: 0.5,
            },
            ticks: {
              callback: function(value, index, values) {
                if (self.periodValue === 'last_month' || self.periodValue === 'this_month') {
                  return this.getLabelForValue(value);
                } else {
                  const label = this.getLabelForValue(value);
                  return self.formatDate(new Date(label));
                }
              },
              font: {
                size: TICK_FONT_SIZE,
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
              borderWidth: 0,
              lineWidth: 0.5,
            },
            ticks: {
              callback: function(value, index, values) {
                return self.makeFriendly(value);
              },
              font: {
                size: TICK_FONT_SIZE,
              },
            },
            stacked: true,
          }
        }
      }
    };
    return config;
  }

  makeChart = (chartDataset, chartType, canvasId, showLegend=false) => {
    ToolTipLine.id = 'ToolTipLine';
    ToolTipLine.defaults = BarController.defaults;
    const defaultBalance = this.balanceValue;

    const externalTooltipHandler = (context) => {
      const {chart, tooltip} = context;
      this.generateExternalLineToolTip(chart, tooltip, chartType);
    };

    Chart.register(ToolTipLine);
    const config = this.initConfig('ToolTipLine', chartDataset, externalTooltipHandler, showLegend)
    const myChart = new Chart(
      document.getElementById(canvasId),
      config,
    );
  }

  generateDataSet = (dataArray) => {
    let dataSet = []
    for (const[i, data] of dataArray.entries()) {
      dataSet.push({
        label: data['label'],
        borderColor: CHART_BORDER_COLORS[i],
        backgroundColor: CHART_BG_COLORS[i],
        hoverBackgroundColor: CHART_BG_COLORS[i],
        borderWidth: 1,
        data: data['trendData'],
        fill: true,
        pointStyle: 'circle',
        categoryPercentage: 0.9,
        barPercentage: 0.9,
        maxBarThickness: 50,
      })
    }
    return dataSet;
  }

  balancesChartTargetConnected(element) {
    console.debug("Balance Chart connected.")
    let self = this
    fetch(`/bank_accounts/${this.bankAccountIdValue}/balances.json?period=${this.periodValue}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data_json => {
      console.debug(data_json)
      const balanceTrend = Object.entries(data_json['balances']).map(function(item) {
        return { x: self.convertDate(item[0]).toDateString(), y: item[1] }
      });

      const dataset = self.generateDataSet([{label: 'Balance', trendData: balanceTrend}]);
      self.makeChart(dataset, 'balance', 'balances-chart')
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }

  cashflowChartTargetConnected(element) {
    console.debug("Cashflow Chart connected.")
    let self = this
    fetch(`/companies/cashflow_trend?period=${this.periodValue}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data_json => {
      console.debug(data_json)
      const assetsTrend = Object.entries(data_json['assets_trend']).map(function(item) {
        return { x: self.convertDate(item[0]).toDateString(), y: item[1] }
      });
      const liabilitiesTrend = Object.entries(data_json['liabilities_trend']).map(function(item) {
        return { x: self.convertDate(item[0]).toDateString(), y: item[1] }
      });
      const dataset = self.generateDataSet([{label: 'Assets', trendData: assetsTrend}, {label: 'Liabilities', trendData: liabilitiesTrend}])
      self.makeChart(dataset, 'cashflow', 'cashflow-chart', true)
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }

  incomeExpenseChartTargetConnected(element) {
    console.debug("Income expense Chart connected.")
    let self = this
    fetch(`/companies/income_expense_trend?period=${this.periodValue}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data_json => {
      console.debug(data_json)
      const incomeTrend = Object.entries(data_json['income_trend']).map(function(item) {
        return { x: self.convertDate(item[0]).toDateString(), y: item[1] }
      });
      const expenseTrend = Object.entries(data_json['expense_trend']).map(function(item) {
        return { x: self.convertDate(item[0]).toDateString(), y: item[1] }
      });
      const dataset = self.generateDataSet([{label: 'Income', trendData: incomeTrend}, {label: 'Expenses', trendData: expenseTrend}])
      self.makeChart(dataset, 'incomeExpense', 'income-expense-chart', true)
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }

  connect() {
    this.darkMode = window.matchMedia('(prefers-color-scheme: dark)').matches
    if (this.darkMode) {
      Chart.defaults.color = '#CCC'
      Chart.defaults.backgroundColor = '#333'
      Chart.defaults.borderColor = '#30363a'
    } else {
      Chart.defaults.color = '#333'
    }
  }
}