import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
// Live search with debounce
export default class extends Controller {
  static targets = ["input", "results", "spinner"]
  static values = {
    url: String,
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

  search() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.performSearch()
    }, this.debounceValue)
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      if (this.hasResultsTarget) {
        this.resultsTarget.innerHTML = ""
      }
      return
    }

    this.showSpinner()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("q", query)

      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok && this.hasResultsTarget) {
        this.resultsTarget.innerHTML = await response.text()
      }
    } catch (error) {
      console.error("Search error:", error)
    } finally {
      this.hideSpinner()
    }
  }

  showSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("d-none")
    }
  }

  hideSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("d-none")
    }
  }

  clear() {
    this.inputTarget.value = ""
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
  }
}
