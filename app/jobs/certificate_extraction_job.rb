# frozen_string_literal: true

class CertificateExtractionJob < ApplicationJob
  queue_as :default

  # This job extracts certificate information from uploaded documents using AI.
  # Uses Google Gemini 1.5 Flash for OCR and data extraction.
  def perform(certificate_id)
    certificate = Certificate.find_by(id: certificate_id)
    return unless certificate
    return unless certificate.document.attached?

    # Mark as processing
    certificate.update!(status: "processing")

    # Extract information from document
    extracted_data = extract_certificate_data(certificate)

    # Update certificate with extracted data
    if extracted_data[:success]
      certificate.update!(
        certificate_number: extracted_data[:certificate_number] || certificate.certificate_number,
        issue_date: extracted_data[:issue_date] || certificate.issue_date,
        expiry_date: extracted_data[:expiry_date] || certificate.expiry_date,
        extracted_data: extracted_data,
        status: "pending" # Back to pending for human review
      )
    else
      # Extraction failed, still mark as pending for manual review
      # Set extraction_method to prevent re-enqueue loop
      certificate.update!(
        extracted_data: extracted_data.merge(extraction_method: extracted_data[:extraction_method] || "failed"),
        status: "pending"
      )
    end

    Rails.logger.info "Certificate ##{certificate_id} extraction completed: #{extracted_data}"
  rescue StandardError => e
    Rails.logger.error "Certificate extraction failed for ##{certificate_id}: #{e.message}"
    # Set extraction_method to prevent re-enqueue loop from after_commit callback
    certificate&.update!(
      status: "pending",
      extracted_data: { error: e.message, extraction_method: "error" }
    )
    raise # Re-raise for job retry
  end

  private

  def extract_certificate_data(certificate)
    # Use mock in test environment
    return mock_extraction_result if Rails.env.test?

    # Use Gemini for real extraction
    if gemini_configured?
      extractor = Ocr::GeminiExtractor.new
      extractor.extract(certificate.document)
    else
      Rails.logger.warn "Gemini API key not configured, using mock extraction"
      mock_extraction_result
    end
  end

  def gemini_configured?
    Rails.application.credentials.gemini_api_key.present? ||
      Rails.application.credentials.dig(:google, :gemini_api_key).present?
  end

  def mock_extraction_result
    {
      success: true,
      confidence: 0.85 + rand * 0.15,
      certificate_number: "MOCK-#{SecureRandom.alphanumeric(8).upcase}",
      issue_date: rand(1..5).years.ago.to_date,
      expiry_date: rand(1..3).years.from_now.to_date,
      issuing_authority: "Mock Authority",
      raw_text: "Mock extracted text from document...",
      extraction_method: "mock"
    }
  end
end
