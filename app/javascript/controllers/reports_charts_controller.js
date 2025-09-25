import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js"

export default class extends Controller {
  static targets = ["salaryBracketsChart", "inssDistributionChart"]
  static values = {
    salaryBracketsData: Object,
    inssDistributionData: Object
  }

  connect() {
    console.log("Reports charts controller connected")
    this.initializeCharts()
  }

  initializeCharts() {
    if (this.hasSalaryBracketsChartTarget) {
      this.createSalaryBracketsChart()
    }

    if (this.hasInssDistributionChartTarget) {
      this.createInssDistributionChart()
    }
  }

  createSalaryBracketsChart() {
    const ctx = this.salaryBracketsChartTarget.getContext('2d')

    new Chart(ctx, {
      type: 'bar',
      data: this.salaryBracketsDataValue,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: true,
            text: 'Employees by INSS Salary Brackets'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  }

  createInssDistributionChart() {
    const ctx = this.inssDistributionChartTarget.getContext('2d')

    new Chart(ctx, {
      type: 'doughnut',
      data: this.inssDistributionDataValue,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom'
          },
          title: {
            display: true,
            text: 'INSS Distribution by Brackets'
          }
        }
      }
    })
  }

  // Method to update charts with new data
  updateCharts(newSalaryData, newInssData) {
    this.salaryBracketsDataValue = newSalaryData
    this.inssDistributionDataValue = newInssData

    // Re-initialize charts with new data
    this.initializeCharts()
  }

  // Method to refresh charts
  refresh() {
    this.initializeCharts()
  }
}
