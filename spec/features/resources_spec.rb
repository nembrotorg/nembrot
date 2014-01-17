# encoding: utf-8

describe 'Resources' do

  include ResourcesHelper

  before(:each) do
    @note = FactoryGirl.create(:note)
  end

  context 'when a note has an image' do
    before do
      @resource = FactoryGirl.create(:resource, note: @note)
      # visit resource_path(cut_image_binary_path(@current_channel, @resource))
    end
  end
end
