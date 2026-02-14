import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm"
// Custom confirmation dialog that looks better than browser default
export default class extends Controller {
  static values = {
    message: { type: String, default: "Are you sure?" },
    title: { type: String, default: "Confirm" }
  }

  confirm(event) {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
