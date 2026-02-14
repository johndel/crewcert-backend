if Rails.env.development?
  ActionMailer::Base.delivery_method = :letter_opener
  ActionMailer::Base.perform_deliveries = true
end
