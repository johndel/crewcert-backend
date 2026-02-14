require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    context 'email uniqueness' do
      subject { create(:user) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe '#full_name' do
    it 'returns the full name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe 'magic link token' do
    it 'generates a magic link token' do
      user = create(:user)
      token = user.generate_token_for(:magic_link)
      expect(token).to be_present
    end

    it 'finds user by valid magic link token' do
      user = create(:user)
      token = user.generate_token_for(:magic_link)
      found_user = User.find_by_token_for(:magic_link, token)
      expect(found_user).to eq(user)
    end

    it 'returns nil for invalid token' do
      found_user = User.find_by_token_for(:magic_link, 'invalid-token')
      expect(found_user).to be_nil
    end
  end

  describe 'password auto-generation' do
    it 'generates a random password if not provided' do
      user = build(:user)
      user.valid?
      expect(user.encrypted_password).to be_present
    end
  end
end
