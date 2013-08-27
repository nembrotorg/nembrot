# encoding: utf-8

describe DiffedNoteVersion, versioning: true do

  before do
    @note = FactoryGirl.create(:note, title: 'First Title', body: 'First body.', tag_list: %w(tag1 tag2 tag3), external_updated_at: 200.minutes.ago)
    @note.update_attributes(title: 'Second Title', body: 'Second body.', tag_list: %w(tag2 tag3 tag4), external_updated_at: 100.minutes.ago)
    @note.update_attributes(title: 'Third Title', body: 'Third body.', tag_list: %w(tag3 tag4 tag5), external_updated_at: 1.minute.ago)
    @diffed_note_version = DiffedNoteVersion.new(@note, 1)
  end

  subject { @diffed_note_version }

  it { should respond_to(:sequence) }
  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:tag_list) }
  it { should respond_to(:previous_title) }
  it { should respond_to(:previous_body) }
  it { should respond_to(:previous_tag_list) }
  it { should respond_to(:is_embeddable_source_url) }
  it { should respond_to(:external_updated_at) }

  context 'when the first version is requested' do
    its(:sequence) { should == 1 }
    its(:title) { should == 'First Title' }
    its(:previous_title) { should == '' }
    its(:body) { should == 'First body.' }
    its(:previous_body) { should == '' }
    its(:tag_list) { should == %w(tag1 tag2 tag3) }
    its(:previous_tag_list) { should == [] }
  end

  context 'when a middle version is requested' do
    before do
      @diffed_note_version = DiffedNoteVersion.new(@note, 2)
    end

    its(:sequence) { should == 2 }
    its(:title) { should == 'Second Title' }
    its(:previous_title) { should == 'First Title' }
    its(:body) { should == 'Second body.' }
    its(:previous_body) { should == 'First body.' }
    its(:tag_list) { should == %w(tag2 tag3 tag4) }
    its(:previous_tag_list) { should == %w(tag1 tag2 tag3) }
  end

  context 'when the last version is requested' do
    before do
      @diffed_note_version = DiffedNoteVersion.new(@note, 3)
    end

    its(:sequence) { should == 3 }
    its(:title) { should == 'Third Title' }
    its(:previous_title) { should == 'Second Title' }
    its(:body) { should == 'Third body.' }
    its(:previous_body) { should == 'Second body.' }
    its(:tag_list) { should == %w(tag3 tag4 tag5) }
    its(:previous_tag_list) { should == %w(tag2 tag3 tag4) }
  end
end
