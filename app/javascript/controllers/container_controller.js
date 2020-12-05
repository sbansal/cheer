import { Controller } from "stimulus"
import uPlot from "uplot"

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
    let data = [
      [1605398400, 1606608000, 1606694400, 1606780800],
      [-105418.2215, -418.2215, 100418.2215, 305418.2215],
      [125418.2215, 105418.2215, 188292, 28472.7405],
    ]
    let uplot = new uPlot(opts,data,document.getElementById('cashflow-trend'))
  }

  connect() {
    console.log("Container connected")
    if (document.getElementById('cashflow-trend')) {
      this.loadCashflowTrends()
    }
  }

  toggle_target(event) {
    this.element.nextElementSibling.classList.toggle('hide')
  }
}