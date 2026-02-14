# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ocr::GeminiExtractor do
  let(:api_key) { "test-api-key" }
  let(:extractor) { described_class.new(api_key: api_key) }

  # Helper to create a mock attachment
  def mock_attachment(content_type:, content: "fake content", attached: true)
    attachment = double("attachment")
    allow(attachment).to receive(:attached?).and_return(attached)
    allow(attachment).to receive(:content_type).and_return(content_type)
    allow(attachment).to receive(:download).and_return(content)
    attachment
  end

  describe "#initialize" do
    context "with explicit API key" do
      it "uses the provided key" do
        extractor = described_class.new(api_key: "explicit-key")
        expect(extractor.instance_variable_get(:@api_key)).to eq("explicit-key")
      end
    end

    context "with credentials API key" do
      before do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:google, :gemini_api_key)
          .and_return("credentials-key")
      end

      it "uses credentials key when no explicit key provided" do
        extractor = described_class.new
        expect(extractor.instance_variable_get(:@api_key)).to eq("credentials-key")
      end
    end

    context "without any API key" do
      before do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:google, :gemini_api_key)
          .and_return(nil)
      end

      it "raises ArgumentError" do
        expect { described_class.new }.to raise_error(ArgumentError, /API key is required/)
      end
    end
  end

  describe "#extract" do
    context "when attachment is nil" do
      it "returns error result" do
        result = extractor.extract(nil)
        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context "when attachment is not attached" do
      let(:attachment) { mock_attachment(content_type: "application/pdf", attached: false) }

      it "returns error result" do
        result = extractor.extract(attachment)
        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context "with unsupported file type" do
      let(:attachment) { mock_attachment(content_type: "text/plain") }

      it "returns error result with unsupported type message" do
        result = extractor.extract(attachment)
        expect(result[:success]).to be false
        expect(result[:error]).to include("Unsupported file type")
      end
    end

    context "with PDF attachment" do
      let(:attachment) { mock_attachment(content_type: "application/pdf") }
      let(:mock_client) { double("Gemini::Client") }

      before do
        allow(Gemini).to receive(:new).and_return(mock_client)
      end

      context "with successful API response" do
        let(:api_response) do
          {
            "candidates" => [{
              "content" => {
                "parts" => [{
                  "text" => '{"certificate_number": "CERT-123", "issue_date": "2024-01-15", "expiry_date": "2029-01-15", "holder_name": "John Doe", "issuing_authority": "Maritime Authority", "certificate_type": "STCW", "confidence": 0.95, "raw_text": "Sample certificate"}'
                }]
              }
            }]
          }
        end

        before do
          allow(mock_client).to receive(:generate_content).and_return(api_response)
        end

        it "returns success result" do
          result = extractor.extract(attachment)
          expect(result[:success]).to be true
        end

        it "extracts certificate_number" do
          result = extractor.extract(attachment)
          expect(result[:certificate_number]).to eq("CERT-123")
        end

        it "parses issue_date" do
          result = extractor.extract(attachment)
          expect(result[:issue_date]).to eq(Date.new(2024, 1, 15))
        end

        it "parses expiry_date" do
          result = extractor.extract(attachment)
          expect(result[:expiry_date]).to eq(Date.new(2029, 1, 15))
        end

        it "extracts holder_name" do
          result = extractor.extract(attachment)
          expect(result[:holder_name]).to eq("John Doe")
        end

        it "extracts issuing_authority" do
          result = extractor.extract(attachment)
          expect(result[:issuing_authority]).to eq("Maritime Authority")
        end

        it "extracts confidence score" do
          result = extractor.extract(attachment)
          expect(result[:confidence]).to eq(0.95)
        end

        it "sets extraction_method" do
          result = extractor.extract(attachment)
          expect(result[:extraction_method]).to eq("gemini-2.0-flash")
        end
      end

      context "with low confidence response" do
        let(:api_response) do
          {
            "candidates" => [{
              "content" => {
                "parts" => [{
                  "text" => '{"certificate_number": null, "confidence": 0.1, "raw_text": "Could not read document"}'
                }]
              }
            }]
          }
        end

        before do
          allow(mock_client).to receive(:generate_content).and_return(api_response)
        end

        it "returns unsuccessful result when confidence is below threshold" do
          result = extractor.extract(attachment)
          expect(result[:success]).to be false
        end
      end

      context "with markdown-wrapped JSON response" do
        let(:api_response) do
          {
            "candidates" => [{
              "content" => {
                "parts" => [{
                  "text" => "```json\n{\"certificate_number\": \"CERT-456\", \"confidence\": 0.9}\n```"
                }]
              }
            }]
          }
        end

        before do
          allow(mock_client).to receive(:generate_content).and_return(api_response)
        end

        it "strips markdown and parses JSON" do
          result = extractor.extract(attachment)
          expect(result[:certificate_number]).to eq("CERT-456")
        end
      end

      context "when API returns invalid JSON" do
        let(:api_response) do
          {
            "candidates" => [{
              "content" => {
                "parts" => [{
                  "text" => "This is not valid JSON"
                }]
              }
            }]
          }
        end

        before do
          allow(mock_client).to receive(:generate_content).and_return(api_response)
        end

        it "returns error result" do
          result = extractor.extract(attachment)
          expect(result[:success]).to be false
          expect(result[:error]).to include("parse")
        end
      end

      context "when API returns empty response" do
        let(:api_response) do
          {
            "candidates" => [{
              "content" => {
                "parts" => [{
                  "text" => ""
                }]
              }
            }]
          }
        end

        before do
          allow(mock_client).to receive(:generate_content).and_return(api_response)
        end

        it "returns error result" do
          result = extractor.extract(attachment)
          expect(result[:success]).to be false
          expect(result[:error]).to be_present
        end
      end

      context "when API request fails" do
        before do
          allow(mock_client).to receive(:generate_content)
            .and_raise(StandardError, "Connection failed")
        end

        it "returns error result" do
          result = extractor.extract(attachment)
          expect(result[:success]).to be false
          expect(result[:error]).to include("Connection failed")
        end

        it "sets extraction_method" do
          result = extractor.extract(attachment)
          expect(result[:extraction_method]).to eq("gemini-2.0-flash")
        end
      end
    end

    context "with image attachment" do
      let(:attachment) { mock_attachment(content_type: "image/jpeg") }
      let(:mock_client) { double("Gemini::Client") }
      let(:api_response) do
        {
          "candidates" => [{
            "content" => {
              "parts" => [{
                "text" => '{"certificate_number": "IMG-789", "confidence": 0.85}'
              }]
            }
          }]
        }
      end

      before do
        allow(Gemini).to receive(:new).and_return(mock_client)
        allow(mock_client).to receive(:generate_content).and_return(api_response)
      end

      it "processes image successfully" do
        result = extractor.extract(attachment)
        expect(result[:success]).to be true
        expect(result[:certificate_number]).to eq("IMG-789")
      end
    end
  end

  describe "date parsing" do
    let(:attachment) { mock_attachment(content_type: "application/pdf") }
    let(:mock_client) { double("Gemini::Client") }

    before do
      allow(Gemini).to receive(:new).and_return(mock_client)
    end

    context "with invalid date format" do
      let(:api_response) do
        {
          "candidates" => [{
            "content" => {
              "parts" => [{
                "text" => '{"issue_date": "invalid-date", "confidence": 0.9}'
              }]
            }
          }]
        }
      end

      before do
        allow(mock_client).to receive(:generate_content).and_return(api_response)
      end

      it "returns nil for unparseable dates" do
        result = extractor.extract(attachment)
        expect(result[:issue_date]).to be_nil
      end
    end

    context "with null date" do
      let(:api_response) do
        {
          "candidates" => [{
            "content" => {
              "parts" => [{
                "text" => '{"issue_date": null, "confidence": 0.9}'
              }]
            }
          }]
        }
      end

      before do
        allow(mock_client).to receive(:generate_content).and_return(api_response)
      end

      it "returns nil for null dates" do
        result = extractor.extract(attachment)
        expect(result[:issue_date]).to be_nil
      end
    end
  end
end
