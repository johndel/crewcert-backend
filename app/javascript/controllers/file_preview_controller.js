import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-preview"
// Shows preview of selected file before upload
export default class extends Controller {
  static targets = ["input", "preview", "placeholder", "filename", "filesize"]
  static values = {
    maxSize: { type: Number, default: 10485760 } // 10MB
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) {
      this.reset()
      return
    }

    // Validate file size
    if (file.size > this.maxSizeValue) {
      alert(`File is too large. Maximum size is ${this.formatSize(this.maxSizeValue)}.`)
      this.inputTarget.value = ""
      this.reset()
      return
    }

    // Update filename and size
    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = file.name
    }
    if (this.hasFilesizeTarget) {
      this.filesizeTarget.textContent = this.formatSize(file.size)
    }

    // Show preview for images
    if (file.type.startsWith("image/") && this.hasPreviewTarget) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("d-none")
        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.classList.add("d-none")
        }
      }
      reader.readAsDataURL(file)
    } else {
      // Show icon for non-images
      if (this.hasPreviewTarget) {
        this.previewTarget.classList.add("d-none")
      }
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.remove("d-none")
        this.placeholderTarget.innerHTML = this.getFileIcon(file.type)
      }
    }
  }

  reset() {
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add("d-none")
      this.previewTarget.src = ""
    }
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove("d-none")
      this.placeholderTarget.innerHTML = '<i class="fas fa-cloud-upload-alt fa-3x text-muted"></i>'
    }
    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = ""
    }
    if (this.hasFilesizeTarget) {
      this.filesizeTarget.textContent = ""
    }
  }

  formatSize(bytes) {
    if (bytes === 0) return "0 Bytes"
    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }

  getFileIcon(mimeType) {
    if (mimeType === "application/pdf") {
      return '<i class="fas fa-file-pdf fa-3x text-danger"></i>'
    }
    return '<i class="fas fa-file fa-3x text-muted"></i>'
  }
}
