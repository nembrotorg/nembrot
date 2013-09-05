# encoding: utf-8

describe User do
  
  before { @user = FactoryGirl.create(:user, role: 'admin') }

  describe '#admin' do
    context 'when role is admin' do
      specify { @user.admin?.should be_true }
    end
    context 'when role is nil' do
      before { @user.role = nil }
      specify { @user.admin?.should_not be_true }
    end
    context 'when role is something else' do
      before { @user.role = 'something else' }
      specify { @user.admin?.should_not be_true }
    end
  end

end
