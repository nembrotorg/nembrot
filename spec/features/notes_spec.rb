describe "Notes" do
  before {
    @note = FactoryGirl.create(:note)
  }

  describe "index page" do
  	before {
      @note.update_attributes( :title => 'New title', :body => 'New body' )
      visit notes_path
    }
    it "should have the title 'Notes'" do
      page.should have_selector('h1', text: I18n.t('notes.title'))
    end
    it "should have a link to note" do
      page.should have_link('New title: New body', href: note_path(@note))
    end
  end

  describe "index page" do
    before {
      Settings.lang['rtl_langs'] = ['ar']
      I18n.locale = 'en'
      @note.update_attributes( :title => 'New title', :body => 'New body', :lang => 'ar' )
      visit notes_path
    }
    it "should have the language attribute if note is not in default language" do
      page.should have_css('ul li a[lang=ar]')
    end
    it "should have the text direction if note is not in default languagex" do
      page.should have_css('ul li a[dir=rtl]')
    end
  end

  describe "show page" do
  	before {
      @note.tag_list = 'tag1'
      @note.save
      visit note_path(@note)
    }
    it "should have the note title as title" do
      page.should have_selector('h1', text: @note.title)
    end
    it "should not have the language attribute (if note is in default language)" do
      page.should_not have_css('#note-content[lang=en]')
    end
    it "should not have the text direction (if note is in default language)" do
      page.should_not have_css('#note-content[dir=rtl]')
    end
    it "should have a link to Notes" do
      page.should have_link(I18n.t('notes.title'), href: notes_path)
    end
    it "should have a link to Tags" do
      page.should have_link(I18n.t('tags.title'), href: tags_path)
    end
    it "should have a link to tag1" do
      page.should have_link('tag1', href: '/tags/tag1')
    end
    it "should have a static label for Version 1" do
      page.should have_selector('li', text: 'v1')
    end
  end

  describe "show page" do
    before {
      Settings.lang['rtl_langs'] = ['ar']
      I18n.locale = 'en'
      @note.lang = 'ar'
      @note.save
      visit note_path(@note)
    }
    it "should have the language attribute if note is not in default language" do
      page.should have_css('#note-content[lang=ar]')
    end
    it "should have the text direction if note is not in default language" do
      page.should have_css('#note-content[dir=rtl]')
    end
  end

  describe "version page", :versioning => true do
    before {
      @note.title = 'Newer title'
      @note.body = 'Newer body'
      @note.tag_list = 'tag1'
      @note.save
      @note.title = 'Newest title'
      @note.body = 'Newest body'
      @note.tag_list = 'tag2'
      @note.save
      visit note_version_path(@note, 3)
    }
    it "should have the note title as title" do
      page.should have_selector('h1', text: @note.title)
    end
    it "should not have the language attribute (if note is in default language)" do
      page.should_not have_css('#note-content[lang=en]')
    end
    it "should not have the text direction (if note is in default language)" do
      page.should_not have_css('#note-content[dir=rtl]')
    end
    it "should have a link to Notes" do
      page.should have_link(I18n.t('notes.title'), href: notes_path)
    end
    it "should have a link to Tags" do
      page.should have_link(I18n.t('tags.title'), href: tags_path)
    end
    it "should have a diffed title" do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it "should have a diffed body" do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it "should have diffed tags" do
      page.should have_selector('del', text: 'tag1')
      page.should have_selector('ins', text: 'tag2')
    end
    it "should have a link to Version 1" do
      page.should have_link('v1', href: note_version_path(@note, 1))
    end
  end

  describe "version page", :versioning => true do
    before {
      Settings.lang['rtl_langs'] = ['ar']
      I18n.locale = 'en'
      @note.lang = 'ar'
      @note.title = 'Newer title'
      @note.save
      @note.title = 'Newest title'
      @note.save
      visit note_version_path(@note, 3)
    }
    it "should have the language attribute if note is not in default language" do
      page.should have_css('#note-content[lang=ar]')
    end
    it "should have the text direction if note is not in default languagex" do
      page.should have_css('#note-content[dir=rtl]')
    end
  end
end
