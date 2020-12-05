import { Controller } from "stimulus"
import uPlot from "uplot"
import Rails from "@rails/ujs"

export default class extends Controller {

  intlFormat(num) {
    return new Intl.NumberFormat().format(Math.round(num*10)/10);
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

  loadCashflowTrends() {
    console.log("chart loading")
    let opts = {
      title: "Assets vs Liabilities ",
      id: "cashflow-trend",
      class: "cashflow-trend",
      width: 550,
      height: 300,
      series: [
        {
          value: (self, rawValue) => new Date(rawValue).toLocaleDateString(),
        },
        {
          label: 'Assets Value',
          stroke: "rgba(112,105,250,1)",
          value: (self, rawValue) => "$" + rawValue.toFixed(2),
          width: 2,
        },
        {
          label: 'Liabilities Value',
          stroke: "#829AB1",
          value: (self, rawValue) => "$" + rawValue.toFixed(2),
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
      },
      error: function(data) {}
    })
  }

  connect() {
    if (document.getElementById('cashflow-trend')) {
      this.loadCashflowTrends()
    }
  }

  toggle_target(event) {
    this.element.nextElementSibling.classList.toggle('hide')
  }
}