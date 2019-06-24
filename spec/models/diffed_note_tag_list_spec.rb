# encoding: utf-8

RSpec.describe DiffedNoteTagList do
  before do
    @note = FactoryGirl.create(:note, tag_list: %w(tag1))
    @diffed_note_tag_list = DiffedNoteTagList.new(%w(tag1 tag2 tag3), %w(tag2 tag3 tag4)).list
  end

  it 'contains each unique item of both lists' do
    expect(@diffed_note_tag_list.size).to eq(4)
  end

  context 'when a tag is deleted' do
    it 'has a status of 1' do
      expect(@diffed_note_tag_list['tag1']['status']).to eq(-1)
    end
  end

  context 'when a tag is retained' do
    it 'has a status of 0' do
      expect(@diffed_note_tag_list['tag2']['status']).to eq(0)
    end
  end

  context 'when a tag is added' do
    it 'has a status of 1' do
      expect(@diffed_note_tag_list['tag4']['status']).to eq(1)
    end
  end

  context 'when a tag still exists' do
    it '#obsolete is false' do
      expect(@diffed_note_tag_list['tag1']['obsolete']).to eq(false)
    end
  end

  context 'when a tag does not exist' do
    it '#obsolete is true' do
      expect(@diffed_note_tag_list['tag2']['obsolete']).to eq(true)
    end
  end
end
