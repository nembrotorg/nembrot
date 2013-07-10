# encoding: utf-8

describe BlurbHelper do

  describe '#blurb' do
    it 'returns a quote and an attribution' do
      blurb('Headline', 'Body.').should ==  ['Headline: ', 'Body.']
    end

    context 'the body starts with the headline' do
      it 'omits the headline from the body' do
        blurb('Headline', 'Headline is already in the body.').should ==  ['Headline', ' is already in the body.']
      end
    end
  end

  describe '#citation_blurb' do
    it 'returns a quote and an attribution' do
      citation_blurb('Plain text.--Kittler 2001').should ==  ['Plain text.', 'Kittler 2001']
    end

    context 'when attribution is not present' do
      it 'returns quote and nil for attribution' do
        citation_blurb('Plain text.').should ==  ['Plain text.', nil]
      end
    end
  end

end
