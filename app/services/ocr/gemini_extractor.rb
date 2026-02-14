# frozen_string_literal: true

module Ocr
  class GeminiExtractor
    PROMPT = <<~PROMPT
      You are analyzing a maritime certificate document. Extract the following information if present:

      1. Certificate Number (any ID, reference number, or certificate number)
      2. Issue Date (when the certificate was issued)
      3. Expiry Date (when the certificate expires, if applicable)
      4. Holder Name (the person the certificate belongs to)
      5. Issuing Authority (organization that issued the certificate)
      6. Certificate Type (e.g., STCW, Medical, CoC, etc.)

      Respond in JSON format only, with these exact keys:
      {
        "certificate_number": "string or null",
        "issue_date": "YYYY-MM-DD or null",
        "expiry_date": "YYYY-MM-DD or null",
        "holder_name": "string or null",
        "issuing_authority": "string or null",
        "certificate_type": "string or null",
        "confidence": 0.0 to 1.0,
        "raw_text": "any other relevant text found"
      }

      If you cannot read the document or it's not a certificate, set confidence to 0 and explain in raw_text.
      Only respond with valid JSON, no other text.
    PROMPT

    def initialize(api_key: nil)
      @api_key = api_key || Rails.application.credentials.dig(:google, :gemini_api_key)
      raise ArgumentError, "Gemini API key is required" if @api_key.blank?
    end

    def extract(attachment)
      raise ArgumentError, "No attachment provided" unless attachment&.attached?

      content = build_content(attachment)
      response = client.generate_content(content)

      parse_response(response)
    rescue Gemini::Errors::RequestError => e
      Rails.logger.error "Gemini API error: #{e.message}"
      error_result(e.message)
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse Gemini response: #{e.message}"
      error_result("Failed to parse AI response")
    rescue StandardError => e
      Rails.logger.error "OCR extraction error: #{e.class} - #{e.message}"
      error_result(e.message)
    end

    private

    def client
      @client ||= Gemini.new(
        credentials: { service: "generative-language-api", api_key: @api_key, version: "v1beta" },
        options: { model: "gemini-2.0-flash" }
      )
    end

    def build_content(attachment)
      content = { contents: { parts: [] } }

      # Add the document
      if attachment.content_type == "application/pdf"
        content[:contents][:parts] << {
          inline_data: {
            mime_type: "application/pdf",
            data: Base64.strict_encode64(attachment.download)
          }
        }
      elsif attachment.content_type.start_with?("image/")
        content[:contents][:parts] << {
          inline_data: {
            mime_type: attachment.content_type,
            data: Base64.strict_encode64(attachment.download)
          }
        }
      else
        raise ArgumentError, "Unsupported file type: #{attachment.content_type}"
      end

      # Add the prompt
      content[:contents][:parts] << { text: PROMPT }

      content
    end

    def parse_response(response)
      # Extract text from Gemini response
      text = response.dig("candidates", 0, "content", "parts", 0, "text")
      raise "Empty response from Gemini" if text.blank?

      # Clean up the response (remove markdown code blocks if present)
      json_text = text.gsub(/```json\n?/, "").gsub(/```\n?/, "").strip

      data = JSON.parse(json_text)

      {
        success: data["confidence"].to_f > 0.3,
        certificate_number: data["certificate_number"],
        issue_date: parse_date(data["issue_date"]),
        expiry_date: parse_date(data["expiry_date"]),
        holder_name: data["holder_name"],
        issuing_authority: data["issuing_authority"],
        certificate_type: data["certificate_type"],
        confidence: data["confidence"].to_f,
        raw_text: data["raw_text"],
        extraction_method: "gemini-2.0-flash"
      }
    end

    def parse_date(date_string)
      return nil if date_string.blank?

      Date.parse(date_string)
    rescue Date::Error
      nil
    end

    def error_result(message)
      {
        success: false,
        error: message,
        confidence: 0,
        extraction_method: "gemini-2.0-flash"
      }
    end
  end
end
