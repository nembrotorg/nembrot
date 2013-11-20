# encoding: utf-8

describe BlurbHelper do

  before(:each) do
    Setting['advanced.blurb_length'] = 40
  end

  describe '#blurb' do
    it 'returns a headline and a blurb' do
      blurb('Headline', 'Body.').should ==  ['Headline: ', 'Body.']
    end

    context 'the body starts with the headline' do
      it 'omits the headline from the body' do
        blurb('Headline', 'Headline is already in the body.').should ==  ['Headline', ' is already in the body.']
      end
    end

    context 'when an introduction is provided' do
      it 'uses the introduction for the blurb' do
        # Review: give option to truncate blurb or not
        blurb('Headline', 'Headline is already in the body.', 'It has a rather long introduction, actually!').should ==  ['Headline: ', 'It has a rather long introduction,...']
      end
    end

    context 'when the introduction is too short' do
      it 'does not use the introduction' do
        blurb('Headline', 'Body.', 'Introduction!').should ==  ['Headline: ', 'Body.']
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
