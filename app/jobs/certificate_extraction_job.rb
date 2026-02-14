# frozen_string_literal: true

class CertificateExtractionJob < ApplicationJob
  queue_as :default

  # This job extracts certificate information from uploaded documents using AI.
  # Currently implemented as a mock - can be replaced with actual AI integration.
  #
  # Supported AI backends (to be implemented):
  # - OpenAI GPT-4 Vision
  # - Claude (Anthropic)
  # - Azure Document Intelligence
  # - Google Cloud Document AI
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
      certificate.update!(
        extracted_data: { error: extracted_data[:error], raw_text: extracted_data[:raw_text] },
        status: "pending"
      )
    end

    Rails.logger.info "Certificate ##{certificate_id} extraction completed: #{extracted_data}"
  rescue StandardError => e
    Rails.logger.error "Certificate extraction failed for ##{certificate_id}: #{e.message}"
    certificate&.update!(
      status: "pending",
      extracted_data: { error: e.message }
    )
    raise # Re-raise for job retry
  end

  private

  def extract_certificate_data(certificate)
    # Mock implementation - simulates AI extraction
    # Replace this with actual AI service call in production

    if Rails.env.test?
      return mock_extraction_result
    end

    # In development/production, we can integrate with AI services
    # For now, return a mock result with realistic delay
    sleep(rand(1..3)) if Rails.env.development?

    mock_extraction_result
  end

  def mock_extraction_result
    # Simulate successful extraction with mock data
    # In real implementation, this would parse the document using AI

    {
      success: true,
      confidence: 0.85 + rand * 0.15, # 85-100% confidence
      certificate_number: generate_mock_certificate_number,
      issue_date: rand(1..5).years.ago.to_date,
      expiry_date: rand(1..3).years.from_now.to_date,
      issuing_authority: ["Maritime Authority", "Flag State Administration", "Classification Society"].sample,
      raw_text: "Mock extracted text from document...",
      extraction_method: "mock_ai"
    }
  end

  def generate_mock_certificate_number
    prefix = %w[CERT COC STCW MED FLAG].sample
    "#{prefix}-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
