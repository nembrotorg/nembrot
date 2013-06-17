# encoding: utf-8

describe DiffedNoteTagList do

  before do
    @note = FactoryGirl.create(:note, tag_list: %w(tag1))
    @diffed_note_tag_list = DiffedNoteTagList.new(%w(tag1 tag2 tag3), %w(tag2 tag3 tag4)).list
  end

  it 'contains each unique item of both lists' do
    @diffed_note_tag_list.size.should == 4
  end

  context 'when a tag is deleted' do
    it 'has a status of 1' do
      @diffed_note_tag_list['tag1']['status'].should == -1
    end
  end

  context 'when a tag is retained' do
    it 'has a status of 0' do
      @diffed_note_tag_list['tag2']['status'].should == 0
    end
  end

  context 'when a tag is added' do
    it 'has a status of 1' do
      @diffed_note_tag_list['tag4']['status'].should == 1
    end
  end

  context 'when a tag still exists' do
    it '#obsolete is false' do
      @diffed_note_tag_list['tag1']['obsolete'].should == false
    end
  end

  context 'when a tag does not exist' do
    it '#obsolete is true' do
      @diffed_note_tag_list['tag2']['obsolete'].should == true
    end
  end
end
