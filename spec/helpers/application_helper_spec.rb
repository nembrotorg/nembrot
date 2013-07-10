# encoding: utf-8

describe ApplicationHelper do

  describe '#lang_attr' do
    before { I18n.locale = 'en' }
    it 'should return the language if different from locale' do
      lang_attr('ar').should == 'ar'
    end
    it 'should return nil if the language is same as locale' do
      lang_attr('en').should == nil
    end
  end

  describe '#body_dir_attr' do
    before { Settings.lang['rtl_langs'] = ['ar'] }
    it 'should return "rtl" if language is rtl' do
      body_dir_attr('ar').should == 'rtl'
    end
    it 'should return "ltr" if language is not rtl' do
      body_dir_attr('en').should == 'ltr'
    end
  end

  describe '#dir_attr' do
    context 'when the note is in the default language' do
      before do
        Settings.lang['rtl_langs'] = ['ar']
        I18n.locale = 'ar'
      end
      it 'returns "ltr" if language is not the same as locale, and is ltr' do
        dir_attr('en').should == 'ltr'
      end
      it 'returns nil if language is the same as locale, and is rtl' do
        dir_attr('ar').should == nil
      end
    end
    context 'when the note is not in the default language' do
      before do
        Settings.lang['rtl_langs'] = ['ar']
        I18n.locale = 'en'
      end
      it 'returns nil if language is the same as locale' do
        dir_attr('en').should == nil
      end
      it 'returns "rtl" if language is not the same as locale, and is rtl' do
        dir_attr('ar').should == 'rtl'
      end
    end
  end
end
