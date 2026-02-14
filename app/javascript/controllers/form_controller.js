import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
// Handles form submission states and validation
export default class extends Controller {
  static targets = ["submit", "spinner"]
  static values = {
    submitText: { type: String, default: "Save" },
    submittingText: { type: String, default: "Saving..." }
  }

  connect() {
    this.originalText = this.hasSubmitTarget ? this.submitTarget.innerHTML : null
  }

  submit(event) {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.innerHTML = `<span class="spinner-border spinner-border-sm me-1"></span>${this.submittingTextValue}`
    }
  }

  reset() {
    if (this.hasSubmitTarget && this.originalText) {
      this.submitTarget.disabled = false
      this.submitTarget.innerHTML = this.originalText
    }
  }

  // Call this when form has errors
  error() {
    this.reset()
    this.element.classList.add("was-validated")
  }
}
