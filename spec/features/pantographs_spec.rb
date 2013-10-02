# encoding: utf-8

describe 'Pantography' do

  before do
    @pantograph = FactoryGirl.create(:pantograph)
    @note = FactoryGirl.create(:note, tag_list: ['pantography'], instruction_list: ['__COPY'])
  end

  describe 'index page' do
    before do
      visit pantographs_path
    end
    specify { page.should_not have_css 'meta[content=noindex]', visible: false }
    specify { page.should have_css 'h1', text: I18n.t('pantographs.index.title') }
    specify { page.should have_css '#pantographs' }
    specify { page.should have_css '.tweeted' }
    specify { page.should have_text @pantograph.body }
    specify { page.should have_text @pantograph.body.length }
    specify { page.should have_text @pantograph.percentage }
    specify { page.should have_selector "a[href='#{ @pantograph.first_path }']" }
    specify { page.should have_selector "a[href='#{ @pantograph.previous_path }']" }
    specify { page.should have_selector "a[href='#{ @pantograph.next_path }']" }
    specify { page.should have_selector "a[href='#{ @pantograph.last_path }']" }
    specify { page.should have_selector "a[href='#{ @pantograph.twitter_url }']" }
    specify { page.should have_selector "a[href='#{ @pantograph.pantographer.twitter_url }']" }
    specify { page.should have_selector "#pantographs a[href='#{ pantograph_path(@pantograph.body) }']" }
  end

  describe 'show page' do
    before do
      visit pantograph_path(@pantograph)
    end
    specify { page.should have_css 'meta[content=noindex]', visible: false }
    specify { page.should have_text @pantograph.to_param }
  end
end
