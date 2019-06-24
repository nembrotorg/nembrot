# encoding: utf-8

RSpec.describe DiffedNoteVersion, versioning: true do
  before do
    ENV['versions'] = 'true'
    @note = FactoryGirl.create(:note, title: 'First Title', body: 'First body.', tag_list: %w(tag1 tag2 tag3), external_updated_at: 200.minutes.ago)
    @note.update_attributes(title: 'Second Title', body: 'Second body.', tag_list: %w(tag2 tag3 tag4), external_updated_at: 100.minutes.ago)
    @note.update_attributes(title: 'Third Title', body: 'Third body.', tag_list: %w(tag3 tag4 tag5), external_updated_at: 1.minute.ago)
    @diffed_note_version = DiffedNoteVersion.new(@note, 1)
  end

  subject { @diffed_note_version }

  it { is_expected.to respond_to(:sequence) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:tag_list) }
  it { is_expected.to respond_to(:previous_title) }
  it { is_expected.to respond_to(:previous_body) }
  it { is_expected.to respond_to(:previous_tag_list) }
  it { is_expected.to respond_to(:is_embeddable_source_url) }
  it { is_expected.to respond_to(:external_updated_at) }

  specify { expect(PaperTrail).to be_enabled }
  specify { expect(@note.versions.size).to eq(2) }

  context 'when the first version is requested' do
    its(:sequence) { is_expected.to eq(1) }
    its(:title) { is_expected.to eq('First Title') }
    its(:previous_title) { is_expected.to eq('') }
    its(:body) { is_expected.to eq('First body.') }
    its(:previous_body) { is_expected.to eq('') }
    its(:tag_list) { is_expected.to eq(%w(tag1 tag2 tag3)) }
    its(:previous_tag_list) { is_expected.to eq([]) }
  end

  context 'when a middle version is requested' do
    before do
      @diffed_note_version = DiffedNoteVersion.new(@note, 2)
    end

    its(:sequence) { is_expected.to eq(2) }
    its(:title) { is_expected.to eq('Second Title') }
    its(:previous_title) { is_expected.to eq('First Title') }
    its(:body) { is_expected.to eq('Second body.') }
    its(:previous_body) { is_expected.to eq('First body.') }
    its(:tag_list) { is_expected.to eq(%w(tag2 tag3 tag4)) }
    its(:previous_tag_list) { is_expected.to eq(%w(tag1 tag2 tag3)) }
  end

  context 'when the last version is requested' do
    before do
      @diffed_note_version = DiffedNoteVersion.new(@note, 3)
    end

    its(:sequence) { is_expected.to eq(3) }
    its(:title) { is_expected.to eq('Third Title') }
    its(:previous_title) { is_expected.to eq('Second Title') }
    its(:body) { is_expected.to eq('Third body.') }
    its(:previous_body) { is_expected.to eq('Second body.') }
    its(:tag_list) { is_expected.to eq(%w(tag3 tag4 tag5)) }
    its(:previous_tag_list) { is_expected.to eq(%w(tag2 tag3 tag4)) }
  end
end
