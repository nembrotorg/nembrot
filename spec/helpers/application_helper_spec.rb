# encoding: utf-8

RSpec.describe ApplicationHelper do
  describe '#lang_attr' do
    before { I18n.locale = 'en' }
    it 'should return the language if different from locale' do
      expect(lang_attr('ar')).to eq('ar')
    end
    it 'should return nil if the language is same as locale' do
      expect(lang_attr('en')).to be_nil
    end
  end

  describe '#body_dir_attr' do
    before { ENV['rtl_langs'] = 'ar' }
    it 'should return "rtl" if language is rtl' do
      expect(body_dir_attr('ar')).to eq('rtl')
    end
    it 'should return "ltr" if language is not rtl' do
      expect(body_dir_attr('en')).to eq('ltr')
    end
  end

  describe '#dir_attr' do
    before { I18n.enforce_available_locales = false }
    context 'when the note is in the default language' do
      before do
        ENV['rtl_langs'] = 'ar'
        I18n.locale = 'ar'
      end
      it 'returns "ltr" if language is not the same as locale, and is ltr' do
        expect(dir_attr('en')).to eq('ltr')
      end
      it 'returns nil if language is the same as locale, and is rtl' do
        expect(dir_attr('ar')).to be_nil
      end
    end
    context 'when the note is not in the default language' do
      before do
        ENV['rtl_langs'] = 'ar'
        I18n.locale = 'en'
      end
      it 'returns nil if language is the same as locale' do
        expect(dir_attr('en')).to be_nil
      end
      it 'returns "rtl" if language is not the same as locale, and is rtl' do
        expect(dir_attr('ar')).to eq('rtl')
      end
    end
  end

  describe '#embeddable_url' do
    specify { expect(embeddable_url('http://www.example.com')).to eq('http://www.example.com') }
    specify { expect(embeddable_url('http://youtube.com?v=ABCDEF')).to eq('http://www.youtube.com/embed/ABCDEF?rel=0') }
    specify { expect(embeddable_url('http://vimeo.com/video/ABCDEF')).to eq('http://player.vimeo.com/video/ABCDEF') }
    specify { expect(embeddable_url('http://vimeo.com/ABCDEF')).to eq('http://player.vimeo.com/video/ABCDEF') }
    specify do 
      expect(embeddable_url('http://soundcloud.com?v=ABCDEF'))
        .to eq('http://w.soundcloud.com/player/?url=http://soundcloud.com?v=ABCDEF') 
    end
  end
end
