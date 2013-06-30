# encoding: utf-8

describe SyncHelper do

  describe 'lang_from_cloud' do
    Settings.notes['wtf_sample_length'] = 10
    VCR.use_cassette('helper/wtf_lang') do
      context 'when text is in Enlish' do
        it 'returns en' do
          lang_from_cloud('The Anatomy of Melancholy').should == 'en'
        end
      end
      context 'when text is in Russian' do
        it 'returns ru' do
          lang_from_cloud('Анатомия меланхолии').should == 'ru'
        end
      end
      context 'when text is in Malaysian' do
        it 'returns ar' do
          lang_from_cloud('അനാട്ടമി ഓഫ് മെലൻകൊളീ').should == 'ml'
        end
      end
      context 'when text is gibberish' do
        it 'returns nil' do
          lang_from_cloud('hsdhasdjkahdjka').should == nil
        end
      end
    end
  end

  describe '#looks_like_a_citation?' do
    it 'returns false for ordinary text' do
      looks_like_a_citation?('Plain text.').should == false
    end
    it 'recognises one-line citations' do
      looks_like_a_citation?("\nquote:Plain text. -- Author 2000\n").should == true
    end
    it 'recognises two-line citations' do
      looks_like_a_citation?("\nquote:Plain text.\n-- Author 2000\n").should == true
    end
    context 'when a note merely contains a citation' do
      context 'when text preceds quote' do
        it 'does not return a false positive' do
          looks_like_a_citation?("Plain text.\nquote:Plain text.\n-- Author 2000\n").should == false
        end
      end
      context 'when succeeds precedes quote' do
        it 'does not return a false positive' do
          looks_like_a_citation?("\nquote:Plain text.\n-- Author 2000\nPlain text.").should == false
        end
      end
      context 'when text surrounds quote' do
        it 'does not return a false positive' do
          looks_like_a_citation?("Plain text.\nquote:Plain text.\n-- Author 2000\nPlain text.").should == false
        end
      end
    end
  end

end
