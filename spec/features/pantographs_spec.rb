# encoding: utf-8

RSpec.describe 'Pantography' do
  before do
    @pantograph = FactoryGirl.create(:pantograph)
    @note = FactoryGirl.create(:note, tag_list: ['pantography'], instruction_list: ['__COPY'])
  end

  describe 'index page' do
    before do
      visit pantographs_path
    end
    specify { expect(page).not_to have_css 'meta[content=noindex]', visible: false }
    specify { expect(page).to have_css 'h1', text: I18n.t('pantographs.index.title') }
    specify { expect(page).to have_css '#pantographs' }
    specify { expect(page).to have_css '.tweeted' }
    specify { expect(page).to have_text @pantograph.text }
    specify { expect(page).to have_text @pantograph.text.length }
    specify { expect(page).to have_text @pantograph.percentage }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.first_path }']" }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.previous_path }']" }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.next_path }']" }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.last_path }']" }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.twitter_url }']" }
    specify { expect(page).to have_selector "a[href='#{ @pantograph.pantographer.twitter_url }']" }
    specify { expect(page).to have_selector "#pantographs a[href='#{ pantograph_path(@pantograph.text) }']" }
  end

  describe 'show page' do
    before do
      visit pantograph_path(@pantograph)
    end
    specify { expect(page).to have_css 'meta[content=noindex]', visible: false }
    specify { expect(page).to have_text @pantograph.to_param }
  end
end
