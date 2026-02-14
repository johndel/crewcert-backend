import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
// Automatically submits form when input changes
export default class extends Controller {
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  submit() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.debounceValue)
  }

  // For select elements - submit immediately
  submitNow() {
    this.element.requestSubmit()
  }
}
