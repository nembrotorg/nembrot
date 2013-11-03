# encoding: utf-8

include ActionView::Helpers::SanitizeHelper
include ApplicationHelper

describe Note do

  let(:note) { FactoryGirl.create(:note, external_updated_at: 200.minutes.ago) }
  subject { note }

  it { should be_valid }
  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:active) }
  it { should respond_to(:author) }
  it { should respond_to(:source) }
  it { should respond_to(:source_url) }
  it { should respond_to(:source_application) }
  it { should respond_to(:last_edited_by) }
  it { should respond_to(:is_embeddable_source_url) }
  it { should respond_to(:fx) }
  it { should respond_to(:active) }
  it { should respond_to(:hide) }
  it { should respond_to(:place) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:altitude) }
  it { should respond_to(:content_class) }

  it { should have_many(:evernote_notes) }
  it { should have_many(:resources) }
  it { should have_many(:tags).through(:tag_taggings) }
  it { should have_many(:instructions).through(:instruction_taggings) }
  it { should have_many(:versions) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:external_updated_at) }

  describe 'rejects update when body, embeddable url and resources are all nil' do
    before do
      note.body = nil
      notesource_url = nil
      note.save
    end
    it { should_not be_valid }
    it { should have(1).error_on(:note) }
  end

  # Not yet implemented
  # describe "refuses update when external_updated_at is unchanged" do
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
  # describe "refuses update when external_updated_at is older" do
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
        note.versions.should_not be_empty
      end
    end
    context 'when title is changed' do
      before do
        note.title = 'New Title'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'saves a version' do
        note.versions.should_not be_empty
      end
    end
    context 'when body is changed' do
      before do
        note.body = 'New Body'
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'saves a version' do
        note.versions.should_not be_empty
      end
    end
    context 'when other attributes (e.g. altitude) is changed' do
      before do
        note.altitude = 1
        note.external_updated_at = 1.minute.ago
        note.save
      end
      it 'does not save a version' do
        note.versions.should be_empty
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
        note.versions.should be_empty
      end
    end

    context 'when a note is not much older or different than the last version' do
      before do
        note.body = note.body + 'a'
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'does not save a version' do
        note.versions.should be_empty
      end
    end

    context 'when a note is not much older but is longer from the last version' do
      before do
        note.body = note.body + ' More than ten words, enough to go over threshold in settings.'
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'saves a version' do
        note.versions.should_not be_empty
      end
    end

    context 'when a note is not much older, is the same length, but is different from the last version' do
      before do
        note.body = note.body.split("").shuffle.join
        note.external_updated_at = 199.minutes.ago
        note.save!
      end
      it 'saves a version' do
        note.versions.should_not be_empty
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
        note.versions.last.external_updated_at.to_i.should == note.versions.last.reify.external_updated_at.to_i
        note.versions.last.instruction_list = %w(__FIRST_INSTRUCTION)
        note.versions.last.sequence.should == note.versions.size
        note.versions.last.tag_list = %w(first_tag)
        note.versions.last.word_count.should == 2
        note.versions.last.distance.should == 51
      end
    end
  end

  describe '#has_instruction?' do
    before do
      Settings.deep_merge!({ 'notes' => { 
        'instructions' => { 'hide' => ['__HIDESYNONYM'], 'default' => ['__DEFAULT_INSTRUCTION'] } } 
      })
      note.instruction_list = %w(__NOTEINSTRUCTION __HIDESYNONYM)
    end
    context 'when an instruction has synonyms in Settings' do
      it 'returns true' do
        note.has_instruction?('hide').should be_true
      end
    end
    context 'when an instruction is set as a synonym' do
      it 'returns true' do
        note.has_instruction?('hidesynonym').should be_true
      end
    end
    context 'when an instruction is set in default for all' do
      it 'returns true' do
        note.has_instruction?('default_instruction').should be_true
      end
    end
    context 'when a note is tagged with an instruction' do
      it 'returns true' do
        note.has_instruction?('noteinstruction').should be_true
      end
    end
    context 'when an instruction is not present' do
      it 'returns false' do
        note.has_instruction?('notpresent').should be_false
      end
    end
  end

  describe '#headline' do
    context 'when title is present' do
      it 'returns title' do
        note.headline.should == note.title
      end
    end
    context 'when title is missing' do
      before do
        note.title = I18n.t('notes.untitled_synonyms').first
      end
      it 'returns preformatted title (e.g. Note 1)' do
        note.headline.should == I18n.t('notes.show.title', id: note.id)
      end
    end
    context 'when title is missing (but in a different case from untitled synonyms)' do
      before do
        note.title = I18n.t('notes.untitled_synonyms').first.upcase
      end
      it 'returns preformatted title (e.g. Note 1)' do
        note.headline.should == I18n.t('notes.show.title', id: note.id)
      end
    end
    context 'when note is a citation' do
      before do
        note.is_citation = true
      end
      it 'returns preformatted title (e.g. Citation 1)' do
        note.headline.should == I18n.t('citations.show.title', id: note.id)
      end
    end
  end

  describe '#type' do
    its(:type) { should == 'Note' } 
    context 'when note is a citation' do
      before do
        note.is_citation = true
      end
      its(:type) { should == 'Citation' } 
    end
  end

  describe 'is taggable' do
    before { note.update_attributes(tag_list: %w(tag1 tag2 tag3)) }
    its(:tag_list) { should == %w(tag1 tag2 tag3) }
  end

  describe 'is findable by tag' do
    before { note.update_attributes(tag_list: 'tag4') }
    # Note.tagged_with('tag4').last.should == note
  end

  describe 'accepts special characters in tags' do
    before do
      note.tag_list = %w(Žižek Café 井戸端)
      note.save
    end
    its(:tag_list) { should == ['Žižek', 'Café', '井戸端'] }
  end


  describe '#clean_body_with_instructions' do
    pending 'TODO'
  end

  describe '#clean_body' do
    pending 'TODO'
  end

  describe '#is_embeddable_source_url' do
    context 'when source_url is not known to be embeddable' do
      before { note.source_url = 'http://www.example.com' }
      its(:is_embeddable_source_url) { should be_false }
    end

    context 'when source_url is a youtube link' do
      before { note.source_url = 'http://youtube.com?v=ABCDEF' }
      its(:is_embeddable_source_url) { should be_true }
    end

    context 'when source_url is a vimeo link' do
      before { note.source_url = 'http://vimeo.com/video/ABCDEF' }
      its(:is_embeddable_source_url) { should be_true }
    end

    context 'when source_url is a soundcloud link' do
      before { note.source_url = 'http://soundcloud.com?v=ABCDEF' }
      its (:is_embeddable_source_url) { should be_true }
    end
  end

  describe '#fx should return fx for images' do
    before { note.instruction_list = %w(__FX_ABC __FX_DEF) }
    its (:fx) { should == 'abc_def' }
  end

  describe '#looks_like_a_citation?' do
    it 'returns false for ordinary text' do
      note = FactoryGirl.create(:note, body: 'Plain text.')
      note.is_citation.should be_false
    end
    it 'recognises one-line citations' do
      note = FactoryGirl.create(:note, body: "\nquote:Plain text. -- Author 2000\n")
      pending 'note.looks_like_a_citation?.should be_true'
    end
    it 'recognises two-line citations' do
      note = FactoryGirl.create(:note, body: "\nquote:Plain text.\n-- Author 2000\n")
      pending 'note.looks_like_a_citation?.should be_true'
    end
    context 'when a note merely contains a citation' do
      context 'when text precedes quote' do
        it 'does not return a false positive' do
          note = FactoryGirl.create(:note, body: "Plain text.\nquote:Plain text.\n-- Author 2000\n")
          note.is_citation.should be_false
        end
      end
      context 'when text succeeds quote' do
        it 'does not return a false positive' do
          note = FactoryGirl.create(:note, body: "\nquote:Plain text.\n-- Author 2000\nPlain text.")
          note.is_citation.should be_false
        end
      end
      context 'when text surrounds quote' do
        it 'does not return a false positive' do
          note = FactoryGirl.create(:note, body: "Plain text.\nquote:Plain text.\n-- Author 2000\nPlain text.")
          note.is_citation.should be_false
        end
      end
    end
  end

  describe 'lang_from_cloud' do
    Settings.notes['detect_language_sample_length'] = 100
    context 'when text is in Enlish' do
      before do
        note.update_attributes(title: 'The Anatomy of Melancholy', body: "Burton's book consists mostly of a.")
      end
      it 'returns en' do
        note.lang.should == 'en'
      end
    end
    context 'when language is given via an instruction' do
      before do
        note.update_attributes(title: 'The Anatomy of Melancholy', body: "Burton's book consists mostly of a.", instruction_list: ['__LANG_MT'])
      end
      it 'does not overwrite it' do
        note.lang.should == 'mt'
      end
    end
    context 'when text is in Russian' do
     before do
       note.update_attributes(title: 'Анатомия меланхолии', body: 'Гигантский том in-quarto толщиной в 900.')
       note.save!
     end
     it 'returns ru' do
       note.lang.should == 'ru'
     end
    end
    context 'when text is in Malaysian' do
      before do
        note.update_attributes(title: 'അനാട്ടമി ഓഫ് മെലൻകൊളീ', body: "'അനാട്ടമി'-യുടെ കർത്താവായ")
      end
      it 'returns ml' do
        note.lang.should == 'ml'
      end
    end
  end
end
