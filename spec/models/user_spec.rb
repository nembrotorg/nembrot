# encoding: utf-8

RSpec.describe User do
  before { @user = FactoryGirl.create(:user, role: 'admin') }

  describe '#admin' do
    context 'when role is admin' do
      specify { expect(@user.admin?).to be_truthy }
    end
    context 'when role is nil' do
      before { @user.role = nil }
      specify { expect(@user.admin?).not_to be_truthy }
    end
    context 'when role is something else' do
      before { @user.role = 'something else' }
      specify { expect(@user.admin?).not_to be_truthy }
    end
  end
end
