# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuperAdmin, type: :model do
  describe 'validations' do
    subject { build(:super_admin) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it 'validates email format' do
      super_admin = build(:super_admin, email: 'invalid')
      expect(super_admin).not_to be_valid
      expect(super_admin.errors[:email]).to be_present
    end

    it 'accepts valid email' do
      super_admin = build(:super_admin, email: 'valid@example.com')
      expect(super_admin).to be_valid
    end
  end

  describe 'magic link token' do
    let(:super_admin) { create(:super_admin) }

    it 'generates a valid token' do
      token = super_admin.generate_token_for(:magic_link)
      expect(token).to be_present
    end

    it 'can find super_admin by token' do
      token = super_admin.generate_token_for(:magic_link)
      found = SuperAdmin.find_by_token_for(:magic_link, token)
      expect(found).to eq(super_admin)
    end

    it 'expires after 1 hour' do
      token = super_admin.generate_token_for(:magic_link)

      travel_to 2.hours.from_now do
        found = SuperAdmin.find_by_token_for(:magic_link, token)
        expect(found).to be_nil
      end
    end
  end

  describe '#ensure_password!' do
    it 'sets password when not present' do
      super_admin = SuperAdmin.new(email: 'test@example.com')
      expect(super_admin.encrypted_password).to be_blank

      super_admin.ensure_password!
      super_admin.reload

      expect(super_admin.encrypted_password).to be_present
    end

    it 'does not change existing password' do
      super_admin = create(:super_admin)
      original_password = super_admin.encrypted_password

      super_admin.ensure_password!
      super_admin.reload

      expect(super_admin.encrypted_password).to eq(original_password)
    end
  end

  describe 'callbacks' do
    it 'auto-generates password on create' do
      super_admin = SuperAdmin.create!(email: 'new@example.com')
      expect(super_admin.encrypted_password).to be_present
    end
  end
end
