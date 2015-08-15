# encoding: utf-8

include ActionView::Helpers::SanitizeHelper
include ApplicationHelper

RSpec.describe Note do
  before(:example) do
    ENV['versions'] = 'true'
    ENV['version_gap_distance'] = '10'
    ENV['version_gap_minutes'] = '60'
  end
  let(:note) { FactoryGirl.create(:note, external_updated_at: 200.minutes.ago, external_created_at: 200.minutes.ago) }
  subject { note }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:active) }
  it { is_expected.to respond_to(:altitude) }
  it { is_expected.to respond_to(:author) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:distance) }
  it { is_expected.to respond_to(:external_updated_at) }
  it { is_expected.to respond_to(:feature) }
  it { is_expected.to respond_to(:fx) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:introduction) }
  it { is_expected.to respond_to(:is_embeddable_source_url) }
  it { is_expected.to respond_to(:last_edited_by) }
  it { is_expected.to respond_to(:latitude) }
  it { is_expected.to respond_to(:longitude) }
  it { is_expected.to respond_to(:place) }
  it { is_expected.to respond_to(:feature_id) }
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:source_application) }
  it { is_expected.to respond_to(:source_url) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:word_count) }

  it { is_expected.to respond_to(:url) }
  it { is_expected.to respond_to(:url_title) }
  it { is_expected.to respond_to(:url_author) }
  it { is_expected.to respond_to(:url_accessed_at) }
  it { is_expected.to respond_to(:url_updated_at) }
  it { is_expected.to respond_to(:url_html) }
  it { is_expected.to respond_to(:url_lang) }

  it { is_expected.to have_many(:evernote_notes) }
  it { is_expected.to have_many(:instructions).through(:instruction_taggings) }
  it { is_expected.to have_many(:resources) }
  it { is_expected.to have_many(:tags).through(:tag_taggings) }
  it { is_expected.to have_many(:versions) }

  it { is_expected.to validate_presence_of(:external_updated_at) }
  it { is_expected.to validate_presence_of(:title) }

  describe 'rejects update when body, embeddable url and resources are all nil' do
    before do
      note.body = nil
      notesource_url = nil
      note.save
    end
    it { is_expected.not_to be_valid }
    it 'has 1 error_on' do
      expect(subject.error_on(:note).size).to eq(1)
    end
  end

  describe 'saves the correct content type' do
    it 'note by default' do
      expect(note.content_type).to eq('note')
    end
    context 'when note has __QUOTE tag' do
      before do
        note.instruction_list = %w(__QUOTE)
        note.save
      end
      it 'content_type is Citation' do
        expect(note.content_type).to eq('citation')
      end
    end
    context 'when note has __LINK tag' do
      before do
        note.instruction_list = %w(__LINK)
        note.save
      end
      it 'content_type is Link' do
        expect(note.content_type).to eq('link')
      end
    end
  end

  # Not yet implemented
  # RSpec.describe "refuses update when external_updated_at is unchanged" do
  #   before do
  #     note.update_attributes(
  #         title: "New Title",
  #         external_updated_at: note.external_updated_at
  #       )
  #   end
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  # Not yet implemented
  # RSpec.describe "refuses update when external_updated_at is older" do
  #   before {
  #     note.update_attributes(
  #         title: "New Title",
  #         external_updated_at: note.external_updated_at - 1
  #       )
  #   }
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  # TODO: Test scopes

  describe 'versioning', versioning: true do
    context 'when title is changed' do
      before do
        note.title = 'New Title'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'saves a version' do
        expect(note.versions).not_to be_empty
      end
    end
    context 'when versions are turned off' do
      before do
        ENV['versions'] = 'false'
        note.title = 'New Title'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'does not save a version' do
        expect(note.versions).to be_empty
      end
    end
    context 'when body is changed' do
      before do
        note.body = 'New Body'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'saves a version' do
        expect(note.versions).not_to be_empty
      end
    end
    context 'when other attributes (e.g. altitude) is changed' do
      before do
        note.altitude = 1
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'does not save a version' do
        expect(note.versions).to be_empty
      end
    end
    context 'when note is tagged to __RESET' do
      before do
        note.instruction_list = %w(__RESET)
        note.body = 'New Body'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'does not save a version' do
        expect(note.versions).to be_empty
      end
    end

    context 'when a note is not much older or different than the last version' do
      before do
        note.body = note.body + 'a'
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'does not save a version' do
        expect(note.versions).to be_empty
      end
    end

    context 'when a note is not much older but is longer from the last version' do
      before do
        note.body = note.body + ' More than ten words, enough to go over threshold in constants.'
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'saves a version' do
        expect(note.versions).not_to be_empty
      end
    end

    context 'when a note is not much older, is the same length, but is different from the last version' do
      before do
        note.body = note.body.reverse
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'saves a version' do
        expect(note.versions).not_to be_empty
      end
    end

    context 'when a version is saved' do
      before do
        note.body = 'First Body'
        note.tag_list = %w(first_tag)
        note.instruction_list = %w(__FIRST_INSTRUCTION)
        note.external_updated_at = 100.minutes.ago
        note.save
        note.body = 'Second Body with more words'
        note.tag_list = %w(second_tag)
        note.instruction_list = %w(__SECOND_INSTRUCTION)
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'saves metadata' do
        expect(note.versions.last.external_updated_at.to_i).to eq(note.versions.last.reify.external_updated_at.to_i)
        note.versions.last.instruction_list = %w(__FIRST_INSTRUCTION)
        expect(note.versions.last.sequence).to eq(note.versions.size)
        note.versions.last.tag_list = %w(first_tag)
        expect(note.versions.last.word_count).to eq(2)
        expect(note.versions.last.distance).to eq(26)
      end
    end
  end

  describe '#has_instruction?' do
    before do
      ENV['instructions_hide'] = '__HIDESYNONYM'
      ENV['instructions_default'] = '__DEFAULT_INSTRUCTION'
      note.instruction_list = %w(__NOTEINSTRUCTION __HIDESYNONYM)
    end
    context 'when an instruction has synonyms in Settings' do
      it 'returns true' do
        expect(note.has_instruction?('hide')).to be_truthy
      end
    end
    context 'when an instruction is set as a synonym' do
      it 'returns true' do
        expect(note.has_instruction?('hidesynonym')).to be_truthy
      end
    end
    context 'when an instruction is set in default for all' do
      it 'returns true' do
        expect(note.has_instruction?('default_instruction')).to be_truthy
      end
    end
    context 'when a note is tagged with an instruction' do
      it 'returns true' do
        expect(note.has_instruction?('noteinstruction')).to be_truthy
      end
    end
    context 'when an instruction is not present' do
      it 'returns false' do
        expect(note.has_instruction?('notpresent')).to be_falsey
      end
    end
  end

  describe '#headline' do
    context 'when title is present' do
      it 'returns title' do
        expect(note.headline).to eq(note.title)
      end
    end
    context 'when title is missing' do
      before do
        note.title = I18n.t('notes.untitled_synonyms').first
      end
      it 'returns preformatted title (e.g. Note 1)' do
        expect(note.headline).to eq(I18n.t('notes.show.title', id: note.id))
      end
    end
    context 'when title is missing (but in a different case from untitled synonyms)' do
      before do
        note.title = I18n.t('notes.untitled_synonyms').first.upcase
      end
      it 'returns preformatted title (e.g. Note 1)' do
        expect(note.headline).to eq(I18n.t('notes.show.title', id: note.id))
      end
    end
    context 'when note is a citation' do
      before do
        note.citation!
      end
      it 'returns preformatted title (e.g. Citation 1)' do
        expect(note.headline).to eq(I18n.t('citations.show.title', id: note.id))
      end
    end
  end

  describe '#inferred_url' do
    context 'when source url exists' do
      before do
        note.source_url = 'http://example.com'
        note.save
      end
      it 'returns source url' do
        expect(note.inferred_url).to eq('http://example.com')
      end
    end
    context 'when source urldoes not exist' do
      before do
        note.source_url = nil
        note.body = 'Normal body. http://example2.com'
        note.save
      end
      it 'returns the first url from the body' do
        expect(note.inferred_url).to eq('http://example2.com')
      end
    end
  end

  describe 'is taggable' do
    before { note.update_attributes(tag_list: %w(tag1 tag2 tag3)) }
    its(:tag_list) { is_expected.to eq(%w(tag1 tag2 tag3)) }
  end

  describe 'is findable by tag' do
    # before { note.update_attributes(tag_list: 'tag4') }
    # Note.tagged_with('tag4').last.should == note
  end

  describe 'accepts special characters in tags' do
    before do
      note.tag_list = %w(Žižek Café 井戸端)
      note.save
    end
    its(:tag_list) { is_expected.to eq(['Žižek', 'Café', '井戸端']) }
  end

  describe '#clean_body_with_instructions' do
    # pending 'TODO'
  end

  describe '#clean_body' do
    # pending 'TODO'
  end

  describe '#is_embeddable_source_url' do
    context 'when source_url is not known to be embeddable' do
      before { note.source_url = 'http://www.example.com' }
      its(:is_embeddable_source_url) { is_expected.to be_falsey }
    end

    context 'when source_url is a youtube link' do
      before { note.source_url = 'http://youtube.com?v=ABCDEF' }
      its(:is_embeddable_source_url) { is_expected.to be_truthy }
    end

    context 'when source_url is a vimeo link' do
      before { note.source_url = 'http://vimeo.com/video/ABCDEF' }
      its(:is_embeddable_source_url) { is_expected.to be_truthy }
    end

    context 'when source_url is a soundcloud link' do
      before { note.source_url = 'http://soundcloud.com?v=ABCDEF' }
      its (:is_embeddable_source_url) { is_expected.to be_truthy }
    end
  end

  describe '#feature_id' do
    context 'when title has no feature_id' do
      before { note.title = 'Title' }
      its (:feature_id) { is_expected.to be_nil }
    end
    context 'when title has a numerical feature_id' do
      before { note.update_attributes(title: '1. Title') }
      its (:feature_id) { is_expected.to eq('1') }
    end
    context 'when title has an alphabetic feature_id' do
      before { note.update_attributes(title: 'a. Title') }
      its (:feature_id) { is_expected.to eq('a') }
    end
    context 'when title has a word as feature_id' do
      before { note.update_attributes(title: 'First. Title') }
      its (:feature_id) { is_expected.to eq('first') }
    end
    context 'when title has a subtitle' do
      before { note.update_attributes(title: 'Main Title: Subtitle') }
      its (:feature_id) { is_expected.to eq('subtitle') }
    end
    context 'when title has more than one word before a period' do
      before { note.update_attributes(title: 'Two words. Title') }
      its (:feature_id) { is_expected.to be_nil }
    end
  end

  describe '#feature' do
    ENV['instructions_feature_first'] = '__FEATURE_FIRST'
    ENV['instructions_feature_last'] = '__FEATURE_LAST'
    before { note.update_attributes(title: 'Title Has Three Words') }
    context 'when note has no instruction' do
      its (:feature) { is_expected.to be_nil }
    end
    context 'when note has feature instruction' do
      before { note.update_attributes(instruction_list: %w(__FEATURE)) }
      its (:feature) { is_expected.to eq('title-has-three-words') }
    end
    context 'when note has an instruction to use the first word' do
      before { note.update_attributes(instruction_list: %w(__FEATURE __FEATURE_FIRST)) }
      its (:feature) { is_expected.to eq('title') }
    end
    context 'when note has an instruction to use the last word' do
      before { note.update_attributes(instruction_list: %w(__FEATURE __FEATURE_LAST)) }
      its (:feature) { is_expected.to eq('words') }
    end
  end

  describe '#fx should return fx for images' do
    before { note.instruction_list = %w(__FX_ABC __FX_DEF) }
    its (:fx) { is_expected.to eq(['abc', 'def']) }
  end

  describe 'lang_from_cloud' do
    ENV['detect_language_sample_length'] = '100'
    context 'when text is in Enlish' do
      before do
        note.update_attributes(title: 'The Anatomy of Melancholy', body: "Burton's book consists mostly of a.", instruction_list: [])
      end
      it 'returns en' do
        expect(note.lang).to eq('en')
      end
    end
    context 'when language is given via an instruction' do
      before do
        note.update_attributes(title: 'The Anatomy of Melancholy', body: "Burton's book consists mostly of a.", lang: nil, instruction_list: ['__LANG_MT'])
      end
      it 'does not overwrite it' do
        expect(note.lang).to eq('mt')
      end
    end
    context 'when text is in Russian' do
     before do
       note.update_attributes(title: 'Анатомия меланхолии', body: 'Автор книги — оксфордский прелат Роберт Бёртон — продолжал дополнять и дописывать книгу до самой смерти в 1640 году.', instruction_list: [])
       note.save!
     end
     it 'returns ru' do
       expect(note.lang).to eq('ru')
     end
    end
    context 'when text is in Malaysian' do
      before do
        note.update_attributes(title: 'അനാട്ടമി ഓഫ് മെലൻകൊളീ', body: "'അനാട്ടമി'-യുടെ കർത്താവായ", instruction_list: [])
      end
      it 'returns ml' do
        expect(note.lang).to eq('ml')
      end
    end
  end
end
