# encoding: utf-8

describe SyncHelper do

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
