import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["salaryInput", "discountDisplay", "discountInput"]
  static values = {
    discountRate: { type: Number, default: 0.1 },
    taxRate: { type: Number, default: 0.2 }
  }

  connect() {
    console.log("Salary calculator controller connected")
    this.calculateDiscount()
  }

  calculateDiscount() {
    const salary = parseFloat(this.salaryInputTarget.value) || 0

    if (salary > 0) {
      // Base discount calculation (you can modify this logic later)
      const discount = this.calculateDiscountAmount(salary)
      const finalAmount = salary - discount

      this.updateDiscountDisplay(salary, discount, finalAmount)
      this.updateDiscountInput(discount)
    } else {
      this.clearDiscountDisplay()
      this.clearDiscountInput()
    }
  }

  calculateDiscountAmount(salary) {
    // Brazilian INSS (Social Security) progressive calculation
    // Based on 2023 tax brackets for Employee, Domestic Employee, and Casual Worker

    const brackets = [
      { min: 0, max: 1045.00, rate: 0.075 },           // 7.5% - Up to R$ 1,045.00
      { min: 1045.01, max: 2089.60, rate: 0.09 },      // 9% - From R$ 1,045.01 to R$ 2,089.60
      { min: 2089.61, max: 3134.40, rate: 0.12 },      // 12% - From R$ 2,089.61 to R$ 3,134.40
      { min: 3134.41, max: 6101.06, rate: 0.14 }       // 14% - From R$ 3,134.41 to R$ 6,101.06
    ]

    let totalDiscount = 0
    let remainingSalary = salary
    let breakdown = []

    for (let bracket of brackets) {
      if (remainingSalary <= 0) break

      // Calculate the taxable amount in this bracket
      const taxableInBracket = Math.min(remainingSalary, bracket.max - bracket.min + 0.01)
      const discountInBracket = taxableInBracket * bracket.rate

      totalDiscount += discountInBracket
      remainingSalary -= taxableInBracket

      // Store breakdown for display
      breakdown.push({
        range: `R$ ${bracket.min.toFixed(2)} - R$ ${bracket.max.toFixed(2)}`,
        taxableAmount: taxableInBracket,
        rate: bracket.rate,
        discount: discountInBracket
      })

      if (remainingSalary <= 0) break
    }

    // Store breakdown for display
    this.breakdown = breakdown

    return Math.round(totalDiscount * 100) / 100 // Round to 2 decimal places
  }

  updateDiscountDisplay(originalSalary, discount, finalAmount) {
    const formattedSalary = this.formatCurrency(originalSalary)
    const formattedDiscount = this.formatCurrency(discount)
    const formattedFinal = this.formatCurrency(finalAmount)

    // Build breakdown details
    let breakdownDetails = ""
    if (this.breakdown && this.breakdown.length > 0) {
      breakdownDetails = "<hr class='my-2'><small><strong>INSS Breakdown:</strong><br>"
      this.breakdown.forEach((bracket, index) => {
        if (bracket.discount > 0) {
          breakdownDetails += `${index + 1}ª bracket: ${this.formatCurrency(bracket.taxableAmount)} × ${(bracket.rate * 100).toFixed(1)}% = ${this.formatCurrency(bracket.discount)}<br>`
        }
      })
      breakdownDetails += "</small>"
    }

    this.discountDisplayTarget.innerHTML = `
      <div class="alert alert-info mb-0">
        <strong>INSS Calculation:</strong><br>
        <small>
          Gross Salary: <strong>${formattedSalary}</strong><br>
          INSS Contribution: <strong>-${formattedDiscount}</strong><br>
          Net Salary: <strong>${formattedFinal}</strong>
        </small>
      </div>
    `
    this.discountDisplayTarget.style.display = "block"
  }

  clearDiscountDisplay() {
    this.discountDisplayTarget.style.display = "none"
  }

  updateDiscountInput(discount) {
    if (this.hasDiscountInputTarget) {
      this.discountInputTarget.value = discount.toFixed(2)
    }
  }

  clearDiscountInput() {
    if (this.hasDiscountInputTarget) {
      this.discountInputTarget.value = ""
    }
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(amount)
  }

  // Method to update discount rate dynamically (for future use)
  updateDiscountRate(newRate) {
    this.discountRateValue = newRate
    this.calculateDiscount()
  }

  // Method to update tax rate dynamically (for future use)
  updateTaxRate(newRate) {
    this.taxRateValue = newRate
    this.calculateDiscount()
  }

  // Test method for the example calculation (R$ 3,000.00)
  // Expected result: R$ 281.62
  testCalculation() {
    const testSalary = 3000.00
    const expectedResult = 281.62

    console.log(`Testing INSS calculation for R$ ${testSalary}`)
    const result = this.calculateDiscountAmount(testSalary)
    console.log(`Expected: R$ ${expectedResult}`)
    console.log(`Actual: R$ ${result}`)
    console.log(`Match: ${Math.abs(result - expectedResult) < 0.01 ? 'YES' : 'NO'}`)

    return result
  }
}
