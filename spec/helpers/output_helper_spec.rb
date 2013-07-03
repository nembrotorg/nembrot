# encoding: utf-8

describe OutputHelper do

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
