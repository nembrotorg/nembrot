# encoding: utf-8

RSpec.describe 'Notes' do
  # REVIEW: Refactor this, use RSpec.describe and consistent selectors

  include ResourcesHelper

  before(:example) do
    ENV['rtl_langs'] = 'ar'
    ENV['blurb_length'] = '40'
    ENV['instructions_map'] = '__MAP'
    ENV['tags_minimum'] = '1'
    ENV['versions'] = 'true'
    ENV['version_gap_distance'] = '10'
    ENV['version_gap_minutes'] = '60'
  end

  describe 'index page' do
    before do
      @note = FactoryGirl.create(:note)
      visit notes_path
    end
    it 'should have the title Notes' do
      expect(page).to have_selector('h1', text: I18n.t('notes.index.title'))
    end
    it 'should have a link to note' do
      expect(page).to have_selector('a', note_path(@note))
    end

    context 'when a note is not active' do
      before do
        @note.update_attributes(title: 'New title', body: 'New body', active: false)
        visit notes_path
      end
      it 'should not have a link to an inactive note' do
        expect(page).not_to have_link(body: 'New title: New body', href: note_path(@note))
      end
    end

    context 'when a note has an introduction' do
      before do
        @note.update_attributes(introduction: 'It has a rather long introduction, actually!')
        visit notes_path
      end
      it 'should display the introduction in the blurb' do
        # Review: give option to truncate blurb or not
        expect(page).to have_text('It has a rather long introduction')
      end
    end

    context 'when no mappable notes exist' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true)
        visit notes_path
      end
      it 'should link to map' do
        expect(page).not_to have_link('See map', href: notes_map_path)
      end
    end

    context 'when a mappable note exists' do
      before do
        @note.update_attributes(latitude: 25, longitude: 25, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        visit notes_path
      end
      it 'should link to map' do
        expect(page).to have_link('See map', href: notes_map_path)
      end
    end

    context 'when a mappable note exists via image' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        @resource = FactoryGirl.create(:resource, latitude: 25, longitude: 25, note: @note)
        visit notes_path
      end
      it 'should link to map' do
        expect(page).to have_link('See map', href: notes_map_path)
      end
    end

    context 'when a note is not in the default language' do
      before do
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.save
        visit notes_path
      end
      it 'has the language attribute if note is not in default language' do
        expect(page).to have_css('ul li a[lang=ar]')
      end
      it 'has the text direction if note is not in default language' do
        expect(page).to have_css('ul li a[dir=rtl]')
      end
    end
  end

  describe 'show page' do
    before do
      ENV['versions'] = 'true'
      ENV['tags_minimum'] = '1'
      @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
      @note.tag_list = ['tag1']
      @note.save
      visit note_path(@note)
    end
    it 'should have the note title as title' do
      expect(page).to have_selector('h1', text: @note.title)
    end
    it 'should contain the body text' do
      expect(page).to have_text(@note.body)
    end
    it 'should have numbered paragraph ids' do
      expect(page).to have_css('#paragraph-1')
    end
    it 'should not have the language attribute (if note is in default language)' do
      expect(page).not_to have_css('#content[lang=en]')
    end
    it 'should not have the text direction (if note is in default language)' do
      expect(page).not_to have_css('#content[dir=rtl]')
    end
    it 'should have a link to Notes' do
      expect(page).to have_link(I18n.t('notes.index.title'), href: notes_path)
    end
    it 'should have a link to Tags' do
      expect(page).to have_link(I18n.t('tags.index.title'), href: tags_path)
    end
    it 'should have a link to tag1' do
      expect(page).to have_link('tag1', href: '/tags/tag1')
    end
    it 'should have a static label for Version 1' do
      expect(page).to have_selector('li', text: 'v1')
    end

    context 'when versions are turned off' do
      before do
        ENV['versions'] = 'false'
        @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
        visit note_path(@note)
      end
      it 'should not have a static label for Version 1' do
        expect(page).not_to have_selector('li', text: 'v1')
      end
    end

    context 'when this tag is attached to fewer notes than threshold' do
      before { ENV['tags_minimum'] = '10' }
      it 'should not have a link to tag1' do
        # # pending "page.should_not have_link('tag1', href: '/tags/tag1')"
      end
    end

    context 'when a note has an introduction' do
      before do
        @note.introduction = 'It has a rather long introduction, actually!'
        @note.save
        visit note_path(@note)
      end
      it 'should display the introduction' do
        expect(page).to have_selector('#introduction p', text: 'It has a rather long introduction, actually!')
      end
    end

    context 'when a note has an introduction and an instruction to hide it' do
      before do
        @note.instruction_list = ['__PUBLISH', '__NO_INTRO']
        @note.introduction = 'It has a rather long introduction, actually!'
        @note.save
        visit note_path(@note)
      end
      it 'should not display the introduction' do
        expect(page).not_to have_selector('#introduction p', text: 'It has a rather long introduction, actually!')
      end
    end

    context 'when a note has an image' do
      before do
        @resource = FactoryGirl.create(:resource, note: @note)
        visit note_path(@note)
      end
      it 'should display attached images' do
        expect(page).to have_css("figure img[src*=\"#{ cut_image_binary_path(@resource) }\"]")
      end
      it 'should display the description in the alt attribute' do
        expect(page).to have_css("figure img[alt*=\"#{ @resource.description }\"]")
      end
      it 'should display the caption for the image' do
        expect(page).to have_selector('figcaption', text: @resource.caption)
      end
    end

    context 'when a note has an attachment' do
      before do
        @resource = FactoryGirl.create(:resource, note: @note, mime: 'application/pdf')
        visit note_path(@note)
      end
      it 'should display downloadable files' do
        # # pending "page.should have_css(\"a[href*=#{@resource.local_file_name}]\")"
      end
    end

    context 'when a note has a youtube video' do
      before do
        @note.update_attributes(source_url: 'http://youtube.com/?v=ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded youtube video' do
        expect(page).to have_css('iframe[src="http://www.youtube.com/embed/ABCDEF?rel=0"]')
      end
    end

    context 'when a note has a vimeo video' do
      before do
        @note.update_attributes(source_url: 'http://vimeo.com/video/ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded vimeo video' do
        expect(page).to have_css('iframe[src="http://player.vimeo.com/video/ABCDEF"]')
      end
    end

    context 'when a note has a soundcloud clip' do
      before do
        @note.update_attributes(source_url: 'http://soundcloud.com/ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded soundcloud video' do
        expect(page).to have_css('iframe[src="http://w.soundcloud.com/player/?url=http://soundcloud.com/ABCDEF"]')
      end
    end

    context 'when a note is in an RTL language' do
      before do
        ENV['rtl_langs'] = 'ar'
        @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'القارئ لطيف، أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.save
        visit note_path(@note)
      end
      it 'has the language attribute if note is not in default language' do
        expect(page).to have_css('#content[lang=ar]')
      end
      it 'has the text direction if note is not in default language' do
        expect(page).to have_css('#content[dir=rtl]')
      end
    end

    context 'when a note has a map' do
      before do
        @note.update_attributes(latitude: 25, longitude: 25, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        visit note_path(@note)
      end
      it 'should display map' do
        # pending "page.should have_css(\"div.map\")"
      end
    end

    context 'when a note has a map via an image' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        @resource = FactoryGirl.create(:resource, latitude: 25, longitude: 25, note: @note)
        visit note_path(@note)
      end
      it 'should display map' do
        # # pending "page.should have_css(\"div.map\")"
      end
    end

    context 'when a note has a reference to a book' do
      before do
        ENV['books_section'] = 'true'
        @book = FactoryGirl.create(:book)
        @note.update_attributes(body: "This note contains a reference to #{ @book.tag }.")
        visit note_path(@note)
      end
      it 'should link to the book' do
        expect(page).to have_css(".body a[href='#{ book_path(@book) }']")
      end
    end

    context 'when a books section is turned off' do
      before do
        ENV['books_section'] = 'false'
        @book = FactoryGirl.create(:book)
        @note.update_attributes(body: "This note contains a reference to #{ @book.tag }.")
        visit note_path(@note)
      end
      it 'should not link to the book' do
        expect(page).not_to have_css(".body a[href='#{ book_path(@book) }']")
      end
    end

    context 'when a note has a reference to another note (using path)' do ####
      before do
        @reference = FactoryGirl.create(:note)
        @note.update_attributes(body: "This note contains a reference to {link: #{ note_path(@reference) }}.")
        visit note_path(@note)
      end
      it 'should link to the other note' do
        expect(page).to have_css(".body a[href='#{ note_path(@reference) }']")
      end
    end

    context 'when a note has a reference to another note (using title)' do
      before do
        @reference = FactoryGirl.create(:note)
        @note.update_attributes(body: "This note contains a reference to {link: #{ @reference.title }}.")
        visit note_path(@note)
      end
      it 'should link to the other note' do
        # # pending "page.should have_css(\"div.map\")"
      end
    end

    context 'when a note has a reference to a citation' do
      before do
        @citation = FactoryGirl.create(:note, content_type: 1)
        @note.update_attributes(body: "This note contains a reference to {link: #{ citation_path(@citation) }}.")
        visit note_path(@note)
      end
      it 'should link to the citation' do
        # # pending "page.should have_css(\".body a[href='#{ citation_path(@citation) }']\")"
      end
    end

    context 'when a note contains a blurb for another note' do
      before do
        @reference = FactoryGirl.create(:note)
        @note.update_attributes(body: "This note contains a reference to {blurb: #{ note_path(@reference) }}.")
        visit note_path(@note)
      end
      it 'should link to the other note' do
        expect(page).to have_css(".body a[href='#{ note_path(@reference) }']")
      end
    end

    context 'when a note contains a blurb for a citation' do
      before do
        @reference = FactoryGirl.create(:note, content_type: 1)
        @note.update_attributes(body: "This note contains a reference to {blurb: #{ citation_path(@reference) }}.")
        visit note_path(@note)
      end
      it 'should link to the other note' do
        # # pending "page.should have_css(\"#content a[href='#{ citation_path(@reference) }']\")"
      end
    end

    context 'when a note contains another note' do ####
      before do
        @reference = FactoryGirl.create(:note)
        @note.update_attributes(body: "This note contains a reference to {text: #{ note_path(@reference) }}.")
        visit note_path(@note)
      end
      it 'should contain the other note' do
        expect(page).to have_text(@reference.body)
      end
    end

    context 'when a note contains another note which contains another note' do
      before do
        @nested_reference = FactoryGirl.create(:note)
        @reference = FactoryGirl.create(:note)
        @note.update_attributes(body: "This note contains a reference to {text: #{ note_path(@reference) }}.")
        visit note_path(@note)
      end
      it 'should contain the text of the nested note' do
        expect(page).to have_text(@nested_reference.body)
      end
    end

    context 'when a note contains a citation' do
      before do
        @citation = FactoryGirl.create(:note, body: 'Citation text', content_type: 1, instruction_list: ['__PUBLISH', '__QUOTE'])
        @note.update_attributes(body: "This note contains a reference to {text: #{ citation_path(@citation) }}.")
        visit note_path(@note)
      end
      it 'should contain the citation' do
        expect(page).to have_text('Citation text')
      end
    end

    context 'when a note has a parallel source text' do
      before do
        @note.update_attributes(active: true, instruction_list: ['__PUBLISH', '__PARALLEL'])
        @source = FactoryGirl.create(:note, body: 'Fixed Note Inhalte verwendet werden, um mehrere Anrufe auf VCR verhindern.', instruction_list: ['__LANG_DE'], title: @note.title)
        visit note_path(@note)
      end
      it 'should have the note title as title' do
        expect(page).to have_selector('h1', text: @note.title)
      end
      it 'should have the source text language' do
        expect(page).to have_css('.source[lang=de]')
      end
      it 'should have the source text direction' do
        # # pending "page.should have_css('.source[dir=rtl]')"
      end
      it 'should have a source text section' do
        expect(page).to have_css('.source')
      end
      it 'should have a target text section' do
        expect(page).to have_css('.target')
      end
      it 'should have the source text' do
        expect(page).to have_text(@source.body)
      end
      it 'should have the target text' do
        expect(page).to have_text(@note.body)
      end
    end

    context 'when a note has a collated parallel source text' do
      before do
        @note.update_attributes(active: true, instruction_list: ['__PUBLISH', '__PARALLEL', '__COLLATE'])
        @source = FactoryGirl.create(:note, body: 'Fixed Note Inhalte verwendet werden, um mehrere Anrufe auf VCR verhindern.', instruction_list: ['__LANG_DE'], title: @note.title)
        visit note_path(@note)
      end
      it 'should have the note title as title' do
        expect(page).to have_selector('h1', text: @note.title)
      end
      it 'should be collated' do
        expect(page).to have_css('.collate')
        expect(page).to have_css('p.source')
        expect(page).to have_css('p.target')
      end
      it 'should have the source text language' do
        expect(page).to have_css('.source[lang=de]')
      end
      it 'should have the source text direction' do
        # # pending "page.should have_css('.source[dir=rtl]')"
      end
      it 'should have a source text section' do
        expect(page).to have_css('.source')
      end
      it 'should have a target text section' do
        expect(page).to have_css('.target')
      end
      it 'should have the source text' do
        expect(page).to have_text(@source.body)
      end
      it 'should have the target text' do
        expect(page).to have_text(@note.body)
      end
    end
  end

  describe 'version page', versioning: true do
    before do
      @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
      @note.title = 'Newer title'
      @note.body = 'Newer body'
      @note.tag_list = ['tag1']
      @note.external_updated_at = 100.minutes.ago
      @note.save
      @note.title = 'Newest title'
      @note.body = 'Newest body with extra characters'
      @note.tag_list = ['tag2']
      @note.external_updated_at = 1.minute.ago
      @note.save
      visit note_version_path(@note, 3)
    end
    it 'should not have the language attribute (if note is in default language)' do
      expect(page).not_to have_css('#content[lang=en]')
    end
    it 'should not have the text direction (if note is in default language)' do
      expect(page).not_to have_css('#content[dir=rtl]')
    end
    it 'should have a link to Notes' do
      expect(page).to have_link(I18n.t('notes.index.title'), href: notes_path)
    end
    it 'should have a link to Tags' do
      expect(page).to have_link(I18n.t('tags.index.title'), href: tags_path)
    end
    it 'should have a diffed title' do
      expect(page).to have_selector('h1 del', text: 'Newer')
      expect(page).to have_selector('h1 ins', text: 'Newest')
    end
    it 'should have a diffed body' do
      expect(page).to have_selector('.body del', text: 'Newer')
      expect(page).to have_selector('.body ins', text: 'Newest')
    end
    it 'should have diffed tags' do
      expect(page).to have_selector('del', text: 'tag1')
      expect(page).to have_selector('ins', text: 'tag2')
    end
    it 'should have a link to Version 1' do
      expect(page).to have_link('v1', href: note_version_path(@note, 1))
    end

    context 'when a note is in an RTL language' do
      before do
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'القارئ لطيف، أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.title = 'تشريح الكآبة الثاني'
        @note.lang = nil
        @note.save
        @note.title = 'تشريح الكآبة الثالث'
        @note.save
        visit note_version_path(@note, 3)
      end
      it 'has the language attribute if note is not in default language' do
        expect(page).to have_css('#content[lang=ar]')
      end
      it 'has the text direction if note is not in default languagex' do
        expect(page).to have_css('#content[dir=rtl]')
      end
    end
  end

  # REVIEW: Test this on all pages using behaves like
  # RSpec.describe 'promotions' do
  #   before do
  #     @note = FactoryGirl.create(:note, instruction_list: ['__PROMOTE'])
  #     visit notes_path
  #   end
  #   it 'should have a link to promoted note' do
  #     page.should have_selector('.promoted a', note_path(@note))
  #   end
  # end

  describe 'qr image' do
    it 'should have the title Notes' do
      # Test this with javascript
      # # pending 'page.should have_css(a[href=#{ qr_code_image_url }])'
    end
  end
  # Test images and embedded media
end
