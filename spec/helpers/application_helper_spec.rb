# encoding: utf-8

describe ApplicationHelper do

  describe '#lang_attr' do
    before { I18n.locale = 'en' }
    it 'should return the language if different from locale' do
      lang_attr('ar').should eq('ar')
    end
    it 'should return nil if the language is same as locale' do
      lang_attr('en').should be_nil
    end
  end

  describe '#body_dir_attr' do
    before { Constant.deep_merge!({ 'rtl_langs' => ['ar'] }) }
    it 'should return "rtl" if language is rtl' do
      body_dir_attr('ar').should eq('rtl')
    end
    it 'should return "ltr" if language is not rtl' do
      body_dir_attr('en').should eq('ltr')
    end
  end

  describe '#dir_attr' do
    context 'when the note is in the default language' do
      before do
        Constant.deep_merge!({ 'rtl_langs' => ['ar'] })
        I18n.locale = 'ar'
      end
      it 'returns "ltr" if language is not the same as locale, and is ltr' do
        dir_attr('en').should eq('ltr')
      end
      it 'returns nil if language is the same as locale, and is rtl' do
        dir_attr('ar').should be_nil
      end
    end
    context 'when the note is not in the default language' do
      before do
        Constant.deep_merge!({ 'rtl_langs' => ['ar'] })
        I18n.locale = 'en'
      end
      it 'returns nil if language is the same as locale' do
        dir_attr('en').should be_nil
      end
      it 'returns "rtl" if language is not the same as locale, and is rtl' do
        dir_attr('ar').should eq('rtl')
      end
    end
  end

  describe '#embeddable_url' do
    specify { embeddable_url('http://www.example.com').should eq('http://www.example.com') }
    specify { embeddable_url('http://youtube.com?v=ABCDEF').should eq('http://www.youtube.com/embed/ABCDEF?rel=0') }
    specify { embeddable_url('http://vimeo.com/video/ABCDEF').should eq('http://player.vimeo.com/video/ABCDEF') }
    specify { embeddable_url('http://vimeo.com/ABCDEF').should eq('http://player.vimeo.com/video/ABCDEF') }
    specify { embeddable_url('http://soundcloud.com?v=ABCDEF')
              .should eq('http://w.soundcloud.com/player/?url=http://soundcloud.com?v=ABCDEF') }
  end

end
