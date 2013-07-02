# encoding: utf-8

include ActionView::Helpers::SanitizeHelper
include ApplicationHelper

describe Note do

  before do
    @note = FactoryGirl.create(:note)
  end

  subject { @note }

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
  it { should respond_to(:embeddable_source_url) }
  it { should respond_to(:fx) }
  it { should respond_to(:active) }
  it { should respond_to(:hide) }

  it { should have_many(:evernote_notes) }
  it { should have_many(:resources) }
  it { should have_many(:tags).through(:tag_taggings) }
  it { should have_many(:instructions).through(:instruction_taggings) }
  it { should have_many(:versions) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:external_updated_at) }

  describe 'rejects update when body, embeddable url and resources are all nil' do
    before do
      @note.update_attributes(
        body: nil,
        source_url: nil
      )
    end
    it { should_not be_valid }
    it { should have(1).error_on(:note) }
  end

  # Not yet implemented
  # describe "refuses update when external_updated_at is unchanged" do
  #   before do
  #     @note.update_attributes(
  #         :title => "New Title",
  #         :external_updated_at => @note.external_updated_at
  #       )
  #   end
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  # Not yet implemented
  # describe "refuses update when external_updated_at is older" do
  #   before {
  #     @note.update_attributes(
  #         :title => "New Title",
  #         :external_updated_at => @note.external_updated_at - 1
  #       )
  #   }
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  # REVIEW: Headlines, blurbs and titles need to be simplified.
  describe 'uses body when title is missing' do
    before { @note.update_attributes(title: I18n.t('notes.untitled_synonyms').first) }
    its(:headline) { should == I18n.t('notes.short', id: @note.id) }
  end

  # describe 'uses title and body for blurb' do
  #   its(:blurb) { should == '<h2>' + @note.headline + '</h2>: ' + @note.body }
  # end

  # describe 'omits title in blurb when title is derived from body' do
  #   before { @note.update_attributes(title: I18n.t('notes.untitled_synonyms').first) }
  #   its(:blurb) { should == '<h2>' + @note.headline + '</h2>: ' + @note.body }
  # end

  describe 'is taggable' do
    before { @note.update_attributes(tag_list: %w(tag1 tag2 tag3)) }
    its(:tag_list) { should == %w(tag1 tag2 tag3) }
  end

  describe 'is findable by tag' do
    before { @note.update_attributes(tag_list: 'tag4') }
    Note.tagged_with('tag4').last.should == @note
  end

  describe 'accepts special characters in tags' do
    before do
      @note.tag_list = %w(Žižek Café 井戸端)
      @note.save
    end
    its(:tag_list) { should == ['Žižek', 'Café', '井戸端'] }
  end

  # describe 'saves versions on every update', versioning: true do
  #  before { @note.update_attributes(title: 'New Title') }
  #  its(:versions) { should > 0 }
  # end

  describe '#embeddable_source_url' do
    before { @note.source_url = 'http://www.example.com' }
    its(:embeddable_source_url) { should be_nil }
  end

  describe '#embeddable_source_url returns an embeddable youtube link if source_url is a youtube link' do
    before { @note.source_url = 'http://youtube.com?v=ABCDEF' }
    its(:embeddable_source_url) { should == 'http://www.youtube.com/embed/ABCDEF?rel=0' }
  end

  describe '#embeddable_source_url returns an embeddable vimeo link if source_url is a vimeo link' do
    before { @note.source_url = 'http://vimeo.com/video/ABCDEF' }
    its(:embeddable_source_url) { should == 'http://player.vimeo.com/video/ABCDEF' }
  end

  describe '#embeddable_source_url returns an embeddable soundcloud link if source_url is a soundcloud link' do
    before { @note.source_url = 'http://soundcloud.com?v=ABCDEF' }
    its (:embeddable_source_url) { should == 'http://w.soundcloud.com/player/?url=http://soundcloud.com?v=ABCDEF' }
  end

  describe '#fx should return fx for images' do
    before { @note.instruction_list = %w(__FX_ABC __FX_DEF) }
    its (:fx) { should == 'abc_def' }
  end

  describe '#looks_like_a_citation?' do
    it 'returns false for ordinary text' do
      @note = FactoryGirl.create(:note, body: 'Plain text.')
      @note.looks_like_a_citation?.should == false
    end
    it 'recognises one-line citations' do
      @note = FactoryGirl.create(:note, body: "\nquote:Plain text. -- Author 2000\n")
      pending "@note.looks_like_a_citation?.should == true"
    end
    it 'recognises two-line citations' do
      @note = FactoryGirl.create(:note, body: "\nquote:Plain text.\n-- Author 2000\n")
      pending "@note.looks_like_a_citation?.should == true"
    end
    context 'when a note merely contains a citation' do
      context 'when text precedes quote' do
        it 'does not return a false positive' do
          @note = FactoryGirl.create(:note, body: "Plain text.\nquote:Plain text.\n-- Author 2000\n")
          @note.looks_like_a_citation?.should == false
        end
      end
      context 'when text succeeds quote' do
        it 'does not return a false positive' do
          @note = FactoryGirl.create(:note, body: "\nquote:Plain text.\n-- Author 2000\nPlain text.")
          @note.looks_like_a_citation?.should == false
        end
      end
      context 'when text surrounds quote' do
        it 'does not return a false positive' do
          @note = FactoryGirl.create(:note, body: "Plain text.\nquote:Plain text.\n-- Author 2000\nPlain text.")
          @note.looks_like_a_citation?.should == false
        end
      end
    end
  end

  describe 'lang_from_cloud' do
    Settings.notes['detect_language_sample_length'] = 100
    context 'when text is in Enlish' do
      it 'returns en' do
      @note = FactoryGirl.create(:note, body: 'The Anatomy of Melancholy')
      VCR.use_cassette('helper/wtf_lang_en') do
        @note.lang_from_cloud.should == 'en'
      end
      end
    end
    context 'when text is in Russian' do
      it 'returns ru' do
        @note = FactoryGirl.create(:note, body: 'Анатомия меланхолии')
        VCR.use_cassette('helper/wtf_lang_ru') do
          @note.lang_from_cloud.should == 'ru'
        end
      end
    end
    context 'when text is in Malaysian' do
      it 'returns ar' do
        @note = FactoryGirl.create(:note, body: 'അനാട്ടമി ഓഫ് മെലൻകൊളീ')
        VCR.use_cassette('helper/wtf_lang_ml') do
          @note.lang_from_cloud.should == 'ml'
        end
      end
    end
   # context 'when text is gibberish' do
   #   it 'returns nil' do
   #     @note = FactoryGirl.create(:note, body: 'hsdhasdjkahdjka')
   #     VCR.use_cassette('helper/wtf_lang_nil') do
   #       @note.lang_from_cloud.should == nil
   #     end
   #   end
   # end
  end

# TEST PUBLISHABLE & Listable !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end
