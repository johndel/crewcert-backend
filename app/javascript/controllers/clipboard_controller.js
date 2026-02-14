import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["source"]
  static values = { successMessage: { type: String, default: "Copied!" } }

  copy(event) {
    event.preventDefault()

    const text = this.sourceTarget.value || this.sourceTarget.textContent
    navigator.clipboard.writeText(text).then(() => {
      this.showFeedback(event.currentTarget)
    })
  }

  showFeedback(button) {
    const originalText = button.innerHTML
    button.innerHTML = `<i class="fas fa-check me-1"></i>${this.successMessageValue}`
    button.classList.add("btn-success")
    button.classList.remove("btn-outline-secondary")

    setTimeout(() => {
      button.innerHTML = originalText
      button.classList.remove("btn-success")
      button.classList.add("btn-outline-secondary")
    }, 2000)
  }
}
