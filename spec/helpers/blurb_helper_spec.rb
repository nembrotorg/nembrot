# encoding: utf-8

describe BlurbHelper do

  before(:example) do
    Setting['advanced.blurb_length'] = 40
  end

  describe '#blurb' do
    it 'returns a headline and a blurb' do
      expect(blurb('Headline', nil, 'Body.')).to eq(['Headline: ', 'Body.'])
    end

    context 'the body starts with the headline' do
      it 'omits the headline from the body' do
        expect(blurb('Headline', nil, 'Headline is already in the body.')).to eq(['Headline', ' is already in the body.'])
      end
    end

    context 'when an introduction is provided' do
      it 'uses the introduction for the blurb' do
        # Review: give option to truncate blurb or not
        expect(blurb('Headline', nil, 'Headline is already in the body.', 'It has a rather long introduction, actually!')).to eq(['Headline: ', 'It has a rather long introduction,...'])
      end
    end

    context 'when the introduction is too short' do
      it 'does not use the introduction' do
        expect(blurb('Headline', nil, 'Body.', 'Introduction!')).to eq(['Headline: ', 'Body.'])
      end
    end
  end

  describe '#citation_blurb' do
    it 'returns a quote and an attribution' do
      expect(citation_blurb('Plain text.--Kittler 2001')).to eq(['Plain text.', 'Kittler 2001'])
    end

    context 'when attribution is not present' do
      it 'returns quote and nil for attribution' do
        expect(citation_blurb('Plain text.')).to eq(['Plain text.', nil])
      end
    end
  end

end
