# encoding: utf-8

RSpec.describe FormattingHelper do
  describe '#bodify' do
    Dir.glob(Rails.root.join('spec', 'support', 'formatting_samples', 'evernote_*_input.txt')) do |sample_file|
      let(:input) { IO.read(sample_file) }
      let(:expected) { IO.read(sample_file.gsub(/input/, 'expected')) }
      # # pending 'specify { bodify(input).should == expected }'
    end
    context 'when text is empty or nil' do
      specify { expect(bodify('')).to eq('') }
      specify { expect(bodify(nil)).to eq('') }
    end
  end

  describe '#blurbify' do
    context 'when text is empty or nil' do
      specify { expect(blurbify('')).to eq('') }
      specify { expect(blurbify(nil)).to eq('') }
    end
  end

  describe '#simple_blurbify' do
    context 'when text is empty or nil' do
      specify { expect(simple_blurbify('')).to eq('') }
      specify { expect(simple_blurbify(nil)).to eq('') }
    end
  end

  describe '#format_blockquotes' do
    it 'converts quotes to block quote' do
      expect(format_blockquotes("Some text.\n{quote:Long quote.}\nMore text."))
        .to eq("Some text.\n\n<blockquote>Long quote.</blockquote>\n\nMore text.")
    end
    context 'when quote has more than one line' do
      it 'converts quotes to block quote' do
        expect(format_blockquotes("Some text.\n{quote:Long quote.\nNew line.}\nMore text."))
          .to eq("Some text.\n\n<blockquote>Long quote.\nNew line.</blockquote>\n\nMore text.")
      end
    end
    #    it 'converts quotes to block quote and includes attribution if present' do
    #      format_blockquotes("Some text.\nquote:Long quote.-- Kittler 2001\nMore text.")
    #        .should == "Some text.\n#{ render citation_partial('blockquote_with_attribution'), citation: 'Long quote.', attribution: 'Kittler 2001') }"
    #        #.should == "Some text.\n<figure class=\"citation\">\n<blockquote>Long quote.</blockquote>\n<figcaption>Kittler 2001</figcaption>\n</figure>\n\nMore text."
    #    end
    #    it 'converts quotes to block quote and includes attribution if present on next paragraph' do
    #      format_blockquotes("Some text.\nquote:Long quote.\n-- Kittler 2001\nMore text.")
    #        .should == "Some text.\n#{ render citation_partial('blockquote_with_attribution'), citation: 'Long quote.', attribution: 'Kittler 2001') }"
    #        .should == "Some text.\n<figure class=\"citation\">\n<blockquote>Long quote.</blockquote>\n<figcaption>Kittler 2001</figcaption>\n</figure>\n\nMore text."
    #    end
  end

  describe '#remove_instructions' do
    it 'removes fork and related notifications' do
      expect(remove_instructions("Some text.\n{fork:/note/31}\nMore text.")).to eq("Some text.\n\nMore text.")
    end
    it 'removes cap:' do
      expect(remove_instructions("Some text.\n{cap: Some other text}\nMore text.")).to eq("Some text.\n\nMore text.")
    end
    it 'removes alt:' do
      expect(remove_instructions("Some text.\n{alt: Some other text}\nMore text.")).to eq("Some text.\n\nMore text.")
    end
    it 'removes credit:' do
      expect(remove_instructions("Some text.\n{credit: Some other text}\nMore text.")).to eq("Some text.\n\nMore text.")
    end
  end

  describe '#sanitize_from_db' do
    it 'truncates all text after --30-- or similar' do
      expect(sanitize_from_db("Text.#{ ENV['truncate_after_regexp'] }THIS SHOULD NOT\n BE INCLUDED."))
        .to eq("\nText.")
    end
    it 'removes superfluous html tags and attributes' do
      expect(sanitize_from_db('Text. <font>More.</font> <strong id="extra">Even more.</strong> <a href="link">Link</a>.'))
        .to eq("\nText. More. <strong>Even more.</strong> <a href=\"link\">Link</a>.\n")
    end
    it 'converts bold tags to strong' do
      expect(sanitize_from_db("Text.\n<b>Bold text.</b>More.")).to eq("\nText.<strong>Bold text.</strong>More.\n")
    end
    it 'converts headline tags to strong' do
      expect(sanitize_from_db("Text.\n<h3>Bold.</h3>More.")).to eq("\nText.<strong>Bold.</strong>More.\n")
    end
  end

  # This should be tested in views.
  #  describe '#bookify' do
  #    before do
  #      @book = FactoryGirl.create(:book, title: 'Discourse Networks 1800/1900',
  #                                 author: 'Friedrich Kittler',
  #                                 published_date: '21 Jan 2000')
  #      @book.valid?
  #      @book.save
  #      @books = Book.all
  #    end
  #    it 'converts inline references' do
  #      bookify('Text is -- Kittler 2000.', @books)
  #        .should == 'Text is -- <a href="/bibliography/kittler-2000">Kittler: Discourse Metworks 1800/1900</a>.'
  #    end
  #  end

  # RSpec.describe '#smartify' do
  #   it 'does not convert double quotes inside html tags' do
  #     smartify('Plain text with <a href="link">link</a> does "nothing silly".')
  #       .should == "Plain text with <a href=\"link\">link</a> does \u201Cnothing silly\u201D."
  #   end
  #   it 'does not convert double quotes inside html tags' do
  #     smartify('Plain "text with <a href="link">link</a> is OK."')
  #       .should == "Plain \u201Ctext with <a href=\"link\">link</a> is OK.\u201D"
  #   end
  # end

  describe '#smartify_hyphens' do
    # it 'converts parenthetical hyphens to en dashes' do
    #   smartify_hyphens('Text is - in a way - just here.').should == "Text is\u2013in a way\u2013just here."
    # end
    it 'converts parenthetical hyphens to en dashes' do
      expect(smartify_hyphens('Text is - in a way - just here.')).to eq("Text is\u2014in a way\u2014just here.")
    end
    it 'converts colon hyphens to em dashes' do
      expect(smartify_hyphens('Text - more text!')).to eq("Text\u2014more text!")
    end
  end

  describe '#smartify_quotation_marks' do
    it 'converts initial inverted comma to a 9' do
      expect(smartify_quotation_marks("More text in '78.")).to eq("More text in \u201978.")
    end
    it 'converts inverted comma inside a word to a 9' do
      expect(smartify_quotation_marks("Don't you forget about me.")).to eq("Don\u2019t you forget about me.")
    end
    it 'converts ironic single quotes to 6 and 9' do
      expect(smartify_quotation_marks("Text with 'ironic' quotes.")).to eq("Text with \u2018ironic\u2019 quotes.")
    end
    it 'converts ironic single quotes to 6 and 9 even when it has abbreviations inside' do
      expect(smartify_quotation_marks("Text 'I'm ironic' quotes.")).to eq("Text \u2018I\u2019m ironic\u2019 quotes.")
    end
    it 'converts double quotes to 66 and 99' do
      expect(smartify_quotation_marks("Text \"I'm ironic\" quotes.")).to eq("Text \u201CI\u2019m ironic\u201D quotes.")
    end
  end

  describe '#smartify_numbers' do
    it 'changes exponents to <sup>' do
      expect(smartify_numbers('1^2')).to eq('1<sup>2</sup>')
    end
  end

  describe '#smartify' do
    # # pending 'Tests.'
  end

  describe '#bookify' do
    # # pending 'Tests.'
  end

  describe '#citation_partial' do
    # # pending 'Tests.'
  end

  describe '#clean_whitespace' do
    it 'replaces multiple new lines with a single new line' do
      expect(clean_whitespace("Some text.\n\nMore text.")).to eq("Some text.\nMore text.")
    end
    it 'strips leading and trailing spaces' do
      expect(clean_whitespace(' Text. More text.  ')).to eq('Text. More text.')
    end
    it 'replaces extra whitespace with a single space' do
      expect(clean_whitespace('Text.  More text.')).to eq('Text. More text.')
    end
    it 'converts non-breaking spaces to ordinary spaces' do
      expect(clean_whitespace('Some&nbsp;text')).to eq('Some text')
    end
  end

  describe '#headerize' do
    it 'converts <strong> paragraphs to headers' do
      expect(headerize("Plain text\n<strong>Header</strong>\nMore plain text"))
        .to eq("Plain text\n<header><h2>Header</h2></header>\nMore plain text")
    end
  end

  describe '#denumber_headers' do
    it 'removes numbers from headers' do
      expect(denumber_headers("Plain text\n<header><h2>1. Header</h2></header>\nMore plain text"))
        .to eq("Plain text\n<header><h2>Header</h2></header>\nMore plain text")
    end
  end

  describe '#sectionize' do
    it 'wraps text under <h2> in a <section>' do
      expect(sectionize("<header><h2>Header</h2></header>\nMore text\n<header><h2>Header</h2></header>\nMore text"))
        .to eq("<section>\n<header><h2>Header</h2></header>\nMore text\n\n</section><section>\n<header><h2>Header</h2></header>\nMore text\n</section>")
    end
  end

  describe '#paragraphize' do
    it 'wraps paragraphs in <p> tags' do
      expect(paragraphize("Plain text\nMore plain text")).to eq("<p>Plain text</p>\n<p>More plain text</p>")
    end
    it 'wraps paragraphs in <p> tags even when they start with <strong>' do
      expect(paragraphize("<strong>Plain</strong> text\nMore plain text"))
        .to eq("<p><strong>Plain</strong> text</p>\n<p>More plain text</p>")
    end
    it 'wraps paragraphs in <p> tags even when they end with <strong>' do
      expect(paragraphize("Plain text\n<strong>More plain</strong> text"))
        .to eq("<p>Plain text</p>\n<p><strong>More plain</strong> text</p>")
    end
    it 'does not wrap headers in <p> tags' do
      expect(paragraphize("Plain text\nMore plain text")).to eq("<p>Plain text</p>\n<p>More plain text</p>")
    end
    it 'does not wrap lists in <p> tags' do
      expect(paragraphize("Plain text\nMore plain text")).to eq("<p>Plain text</p>\n<p>More plain text</p>")
    end
  end
end
