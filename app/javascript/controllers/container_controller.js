import { Controller } from "stimulus"
import uPlot from "uplot"
import Rails from "@rails/ujs"
import {seriesBarsPlugin} from "../packs/seriesBarPlugin.js"

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
export default class extends Controller {

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

  loadCashflowTrends() {
    console.debug("loadCashflowTrends")
    let opts = {
      title: "Assets vs Liabilities ",
      id: "cashflow-trend-chart",
      class: "cashflow-trend-chart",
      width: document.getElementById('cashflow-trend').offsetWidth,
      height: 300,
      series: [
        {
          label: 'Date',
          value: (self, rawValue) => new Date(rawValue*1000).toLocaleDateString(),
        },
        {
          label: 'Assets',
          stroke: "rgba(112,105,250,1)",
          value: (self, rawValue) => this.intlFormat(rawValue, 'USD'),
          width: 2,
        },
        {
          label: 'Liabilities',
          stroke: "#829AB1",
          value: (self, rawValue) => this.intlFormat(rawValue, 'USD'),
          width: 2,
        }
      ],
      axes: [
        {
          grid: {
            stroke: "#F0F4F8",
            width: 1,
          },
          ticks: {
            show: true,
            stroke: "#F0F4F8",
            width: 1,
            size: 10,
          }
        },
        {
          labelSize: 60,
          size: 60,
          values: (self, ticks) => ticks.map(rawValue => this.makeFriendly(rawValue)),
          grid: {
            stroke: "#F0F4F8",
            width: 1,
          },
          ticks: {
            show: true,
            stroke: "#F0F4F8",
            width: 1,
            size: 10,
          }
        },
      ]
    }

    Rails.ajax({
      url: "/accounts/cashflow_trend",
      type: "get",
      dataType: 'json',
      success: function(data_response) {
        var assets_trend_map = new Map(Object.entries(data_response['assets_trend']))
        let liabilities_trend_map = new Map(Object.entries(data_response['liabilities_trend']))
        let data = [
          Array.from(assets_trend_map.keys(), date_str => new Date(date_str).getTime() / 1000),
          Array.from(assets_trend_map.values()),
          Array.from(liabilities_trend_map.values()),
        ]
        let uplot = new uPlot(opts,data,document.getElementById('cashflow-trend'))
        document.getElementById('cashflow-trend').classList.add('show')
      },
      error: function(data) {}
    })
  }

  makeChart(d) {
    const opts = {
      title: "Income vs Expenses ",
      id: "income-expense-trend-chart",
      class: "income-expense-trend-chart",
      width: document.getElementById('income-expense-trend').offsetWidth,
      height: 300,
      axes: [
        {
          grid: {
            stroke: "#F0F4F8",
            width: 1,
          },
          ticks: {
            show: true,
            stroke: "#F0F4F8",
            width: 1,
            size: 5,
          }
        },
        {
          labelSize: 60,
          size: 60,
          values: (self, ticks) => ticks.map(rawValue => this.makeFriendly(rawValue)),
          grid: {
            stroke: "#F0F4F8",
            width: 1,
          },
          ticks: {
            show: true,
            stroke: "#F0F4F8",
            width: 1,
            size: 10,
          }
        },
      ],
      series: [
        {
          label: 'Month',
          value: (self, rawValue) => this.formatDate(new Date(d[0][rawValue])),
        },
        {
          label: 'Income',
          stroke: "#7069fa",
          fill: "#7069fa8c",
          value: (self, rawValue) => this.intlFormat(rawValue, 'USD'),
          width: 1,
        },
        {
          label: 'Expense',
          stroke: "#829AB1",
          fill: "#829AB18c",
          value: (self, rawValue) => this.intlFormat(rawValue, 'USD'),
          width: 1,
        },
        {
          label: 'Savings',
          stroke: "#a269fa",
          fill: "#a269fa8c",
          value: (self, rawValue) => this.intlFormat(rawValue, 'USD'),
          width: 1,
        },
      ],
      plugins: [
        seriesBarsPlugin({
          xLabels: d[0].map (item => this.formatDate(new Date(item))),
        }),
      ],
    };

    const enabled = Array(d.length).fill(true);

    function makeData() {
      return [
        d[0].map((item, i) => i),
        d[1],
        d[2],
        d[3],
        d[0],
      ];
    }
    let data = makeData()
    console.log(data)
    let uplot = new uPlot(opts, data, document.getElementById('income-expense-trend'))
    document.getElementById('income-expense-trend').classList.add('show')
  }

  loadIncomeExpenseTrends() {
    console.debug("loadIncomeExpenseTrends")
    self = this
    Rails.ajax({
      url: "/accounts/income_expense_trend",
      type: "get",
      dataType: 'json',
      success: function(data_response) {
        let assets_trend_map = new Map(Object.entries(data_response['income_trend']))
        let liabilities_trend_map = new Map(Object.entries(data_response['expense_trend']))
        let saving_trend_map = new Map(Object.entries(data_response['saving_trend']))
        let data = [
          Array.from(assets_trend_map.keys(), date_str => new Date(date_str).getTime()),
          Array.from(assets_trend_map.values()),
          Array.from(liabilities_trend_map.values()),
          Array.from(saving_trend_map.values()),
        ]
        console.log(data)
        self.makeChart(data)
      },
      error: function(data) {}
    })
  }

  connect() {
    if (document.getElementById('cashflow-trend')
      && document.getElementById('cashflow-trend').children.length == 0 ) {
      this.loadCashflowTrends()
    } else if (document.getElementById('income-expense-trend')
        && document.getElementById('income-expense-trend').children.length == 0 ) {
      this.loadIncomeExpenseTrends()
    }
  }

  toggle_target(event) {
    this.element.nextElementSibling.classList.toggle('hide')
  }
}