# frozen_string_literal: true

module Matrix
  class CopyRequirementsService < ApplicationService
    def initialize(source_vessel:, target_vessel:, overwrite: false)
      @source_vessel = source_vessel
      @target_vessel = target_vessel
      @overwrite = overwrite
    end

    def call
      return failure("Source and target vessels cannot be the same") if source_vessel == target_vessel
      return failure("Source vessel has no requirements") if source_requirements.empty?

      ActiveRecord::Base.transaction do
        target_vessel.matrix_requirements.destroy_all if overwrite

        copied = copy_requirements
        success({ copied: copied, total: source_requirements.size })
      end
    rescue ActiveRecord::RecordInvalid => e
      failure("Failed to copy: #{e.message}")
    end

    private

    attr_reader :source_vessel, :target_vessel, :overwrite

    def source_requirements
      @source_requirements ||= source_vessel.matrix_requirements.includes(:role, :certificate_type)
    end

    def copy_requirements
      copied = 0

      source_requirements.find_each do |requirement|
        existing = target_vessel.matrix_requirements.find_by(
          role: requirement.role,
          certificate_type: requirement.certificate_type
        )

        if existing
          next unless overwrite
          existing.update!(requirement_level: requirement.requirement_level)
        else
          target_vessel.matrix_requirements.create!(
            role: requirement.role,
            certificate_type: requirement.certificate_type,
            requirement_level: requirement.requirement_level
          )
        end

        copied += 1
      end

      copied
    end
  end
end
