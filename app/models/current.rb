# frozen_string_literal: true

# Current provides a way to access request-specific attributes
# throughout the application, particularly useful for auditing.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :request_id
  attribute :ip_address

  def user_id
    user&.id
  end
end
