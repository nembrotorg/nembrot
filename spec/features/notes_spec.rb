# encoding: utf-8

describe 'Notes' do

  # REVIEW: Refactor this, use describe and consistent selectors

  include ResourcesHelper

  describe 'index page' do
    before do
      @note = FactoryGirl.create(:note)
      visit notes_path
    end
    it 'should have the title Notes' do
      page.should have_selector('h1', text: I18n.t('notes.index.title'))
    end
    it 'should have a link to note' do
      page.should have_selector('a', note_path(@note))
    end

    context 'when a note is not active' do
      before do
        @note.update_attributes(title: 'New title', body: 'New body', active: false)
        visit notes_path
      end
      it 'should not have a link to an inactive note' do
        page.should_not have_link(text: 'New title: New body', href: note_path(@note))
      end
    end

    context 'when no mappable notes exist' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true)
        visit notes_path
      end
      it 'should link to map' do
        page.should_not have_link('See map', href: notes_map_path)
      end
    end

    context 'when a mappable note exists' do
      before do
        @note.update_attributes(latitude: 25, longitude: 25, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        visit notes_path
      end
      it 'should link to map' do
        page.should have_link('See map', href: notes_map_path)
      end
    end

    context 'when a mappable note exists via image' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        @resource = FactoryGirl.create(:resource, latitude: 25, longitude: 25, note: @note)
        visit notes_path
      end
      it 'should link to map' do
        page.should have_link('See map', href: notes_map_path)
      end
    end

    context 'when a note is not in the default language' do
      before do
        Constant.deep_merge!({ 'rtl_langs' => ['ar'] })
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.save
        visit notes_path
      end
      it 'has the language attribute if note is not in default language' do
        page.should have_css('ul li a[lang=ar]')
      end
      it 'has the text direction if note is not in default language' do
        page.should have_css('ul li a[dir=rtl]')
      end
    end
  end

  describe 'show page' do
    before do
      @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
      @note.tag_list = ['tag1']
      @note.save
      visit note_path(@note)
    end
    it 'should have the note title as title' do
      page.should have_selector('h1', text: @note.title)
    end
    it 'should not have the language attribute (if note is in default language)' do
      page.should_not have_css('#content[lang=en]')
    end
    it 'should not have the text direction (if note is in default language)' do
      page.should_not have_css('#content[dir=rtl]')
    end
    it 'should have a link to Notes' do
      page.should have_link(I18n.t('notes.index.title'), href: notes_path)
    end
    it 'should have a link to Tags' do
      page.should have_link(I18n.t('tags.index.title'), href: tags_path)
    end
    it 'should have a link to tag1' do
      page.should have_link('tag1', href: '/tags/tag1')
    end
    it 'should have a static label for Version 1' do
      page.should have_selector('li', text: 'v1')
    end

    context 'when a note has an image' do
      before do
        @resource = FactoryGirl.create(:resource, note: @note)
        visit note_path(@note)
      end
      it 'should display attached images' do
        page.should have_css("figure img[src*=\"#{ cut_image_binary_path(@resource) }\"]")
      end
      it 'should display the description in the alt attribute' do
        page.should have_css("figure img[alt*=\"#{ @resource.description }\"]")
      end
      it 'should display the caption for the image' do
        page.should have_selector('figcaption', text: @resource.caption)
      end
    end

    context 'when a note has an attachment' do
      before do
        @resource = FactoryGirl.create(:resource, note: @note, mime: 'application/pdf')
        visit note_path(@note)
      end
      it 'should display downloadable files' do
        pending "page.should have_css(\"a[href*=#{@resource.local_file_name}]\")"
      end
    end

    context 'when a note has a youtube video' do
      before do
        @note.update_attributes(source_url: 'http://youtube.com/?v=ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded youtube video' do
        page.should have_css('iframe[src="http://www.youtube.com/embed/ABCDEF?rel=0"]')
      end
    end

    context 'when a note has a vimeo video' do
      before do
        @note.update_attributes(source_url: 'http://vimeo.com/video/ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded vimeo video' do
        page.should have_css('iframe[src="http://player.vimeo.com/video/ABCDEF"]')
      end
    end

    context 'when a note has a soundcloud clip' do
      before do
        @note.update_attributes(source_url: 'http://soundcloud.com/ABCDEF')
        visit note_path(@note)
      end
      it 'should have an iframe with an embedded soundcloud video' do
        page.should have_css('iframe[src="http://w.soundcloud.com/player/?url=http://soundcloud.com/ABCDEF"]')
      end
    end

    context 'when a note is in an RTL language' do
      before do
        @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
        Constant.deep_merge!({ 'rtl_langs' => ['ar'] })
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'القارئ لطيف، أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.save
        visit note_path(@note)
      end
      it 'has the language attribute if note is not in default language' do
        page.should have_css('#content[lang=ar]')
      end
      it 'has the text direction if note is not in default language' do
        page.should have_css('#content[dir=rtl]')
      end
    end

    context 'when a note has a map' do
      before do
        @note.update_attributes(latitude: 25, longitude: 25, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        visit note_path(@note)
      end
      it 'should display map' do
        pending "page.should have_css(\"div.map\")"
      end
    end

    context 'when a note has a map via an image' do
      before do
        @note.update_attributes(latitude: nil, longitude: nil, active: true, instruction_list: ['__PUBLISH', '__MAP'])
        @resource = FactoryGirl.create(:resource, latitude: 25, longitude: 25, note: @note)
        visit note_path(@note)
      end
      it 'should display map' do
        pending "page.should have_css(\"div.map\")"
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
      @note.body = 'Newest body'
      @note.tag_list = ['tag2']
      @note.external_updated_at = 1.minute.ago
      @note.save
      visit note_version_path(@note, 3)
    end
    it 'should have the note title as title' do
      page.should have_selector('h1', text: '<del>Newer</del><ins>Newest</ins> title v3')
    end
    it 'should not have the language attribute (if note is in default language)' do
      page.should_not have_css('#content[lang=en]')
    end
    it 'should not have the text direction (if note is in default language)' do
      page.should_not have_css('#content[dir=rtl]')
    end
    it 'should have a link to Notes' do
      page.should have_link(I18n.t('notes.index.title'), href: notes_path)
    end
    it 'should have a link to Tags' do
      page.should have_link(I18n.t('tags.index.title'), href: tags_path)
    end
    it 'should have a diffed title' do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it 'should have a diffed body' do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it 'should have diffed tags' do
      page.should have_selector('del', text: 'tag1')
      page.should have_selector('ins', text: 'tag2')
    end
    it 'should have a link to Version 1' do
      page.should have_link('v1', href: note_version_path(@note, 1))
    end

    context 'when a note is in an RTL language' do
      before do
        Constant.deep_merge!({ 'rtl_langs' => ['ar'] })
        I18n.locale = 'en'
        @note.instruction_list = ['__LANG_AR']
        @note.title = 'تشريح الكآبة'
        @note.body = 'القارئ لطيف، أفترض انت الذبول يكون فضولي جدا لمعرفة ما الفاعل انتيتش أو جسد هو هذا، بحيث بكل وقاحة'
        @note.title = 'تشريح الكآبة الثاني'
        @note.save
        @note.title = 'تشريح الكآبة الثالث'
        @note.save
        visit note_version_path(@note, 3)
      end
      it 'has the language attribute if note is not in default language' do
        page.should have_css('#content[lang=ar]')
      end
      it 'has the text direction if note is not in default languagex' do
        page.should have_css('#content[dir=rtl]')
      end
    end
  end

  # REVIEW: Test this on all pages using behaves like
  # describe 'promotions' do
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
      pending 'page.should have_css(a[href=#{ qr_code_image_url }])'
    end
  end
  # Test images and embedded media
end
