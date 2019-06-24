# encoding: utf-8

RSpec.describe CitationsHelper do
  before do
    @note1 = FactoryGirl.create(:note, body: 'Anhtropology --p57')
    @note2 = FactoryGirl.create(:note, body: 'Zoology--p11')
    @note3 = FactoryGirl.create(:note, body: 'Zoology--p101')
  end

  describe '#sort_by_page_reference' do
    unsorted_citations = Note.all

    it 'sorts blurbs according to page number' do
      expect(sort_by_page_reference(unsorted_citations).first.body).to eq('Zoology--p11')
      expect(sort_by_page_reference(unsorted_citations).last.body).to eq('Zoology--p101')
    end
  end
end
