# encoding: utf-8

RSpec.describe BlurbHelper do
  before(:example) do
    ENV['blurb_length'] = '100'
  end

  describe '#blurb' do
    it 'returns a headline and a blurb' do
      expect(blurb('Headline', nil, 'Body.')).to eq(['Headline ', 'Body.'])
    end

    context 'the body starts with the headline' do
      it 'wraps the headline in a classed span' do
        expect(blurb('Headline', nil, 'Headline is already in the body.')).to eq(["Headline", "<span class=\"repeated-headline\">Headline</span> is already in the body."])
      end
    end

    context 'when an introduction is provided' do
      it 'uses the introduction for the blurb' do
        # Review: give option to truncate blurb or not
        expect(blurb('Headline', nil, 'Headline is already in the body.', 'It has a rather long introduction, actually!')).to eq(["Headline ", "It has a rather long introduction, actually! Headline is already in the body."])
      end
    end

    context 'when a subtitle is provided' do
      it 'has both title and subtitle' do
        # Review: give option to truncate blurb or not
        expect(blurb('Headline', 'Subtitle', 'Text for blurb is also provided.')).to eq(["<span>Headline: </span>Subtitle ", "Text for blurb is also provided."])
      end
    end

    context 'when a headline is repeated but a subtitle is provided' do
      it 'does not wrap the headline in a classed span' do
        # Review: give option to truncate blurb or not
        expect(blurb('Headline', 'Subtitle', 'Headline is in the introduction.')).to eq(["<span>Headline: </span>Subtitle ", "Headline is in the introduction."])
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
