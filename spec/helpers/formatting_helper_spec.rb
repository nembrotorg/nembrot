# encoding: utf-8

describe FormattingHelper do

  describe '#bodify' do
    Dir.glob(Rails.root.join('spec', 'support', 'formatting_samples', 'evernote_*_input.txt')) do |sample_file|
      let(:input) { IO.read(sample_file) }
      let(:expected) { IO.read(sample_file.gsub(/input/, 'expected')) }
      pending "specify { bodify(input).should == expected }"
    end
    context 'when text is empty or nil' do
      specify { bodify('').should eq('') }
      specify { bodify(nil).should eq('') }
    end
  end

  describe '#blurbify' do
    context 'when text is empty or nil' do
      specify { blurbify('').should eq('') }
      specify { blurbify(nil).should eq('') }
    end
  end

  describe '#simple_blurbify' do
    context 'when text is empty or nil' do
      specify { simple_blurbify('').should eq('') }
      specify { simple_blurbify(nil).should eq('') }
    end
  end

  describe '#format_blockquotes' do
    it 'converts quotes to block quote' do
      format_blockquotes("Some text.\nquote:Long quote.\nMore text.")
        .should == "Some text.\n\n<blockquote>Long quote.</blockquote>\n\nMore text."
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
      remove_instructions("Some text.\nfork:/note/31\nMore text.").should == "Some text.\n\nMore text."
    end
    it 'removes cap:' do
      remove_instructions("Some text.\ncap:/Some other text\nMore text.").should == "Some text.\n\nMore text."
    end
    it 'removes alt:' do
      remove_instructions("Some text.\nalt:/Some other text\nMore text.").should == "Some text.\n\nMore text."
    end
    it 'removes credit:' do
      remove_instructions("Some text.\ncredit:/Some other text\nMore text.").should == "Some text.\n\nMore text."
    end
  end

  describe '#sanitize_from_db' do
    it 'truncates all text after --30-- or similar' do
      sanitize_from_db("Text.#{ Setting['advanced.truncate_after_regexp'] }THIS SHOULD NOT\n BE INCLUDED.")
        .should == 'Text.'
    end
    it 'removes superfluous html tags and attributes' do
      sanitize_from_db('Text. <font>More.</font> <strong id="extra">Even more.</strong> <a href="link">Link</a>.')
        .should == 'Text. More. <strong>Even more.</strong> <a href="link">Link</a>.'
    end
    it 'converts bold tags to strong' do
      sanitize_from_db("Text.\n<b>Bold text.</b>More.").should == "Text.\n<strong>Bold text.</strong>More."
    end
    it 'converts headline tags to strong' do
      sanitize_from_db("Text.\n<h3>Bold.</h3>More.").should == "Text.\n<strong>Bold.</strong>More."
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

  # describe '#smartify' do
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
      smartify_hyphens('Text is - in a way - just here.').should == "Text is\u2014in a way\u2014just here."
    end
    it 'converts colon hyphens to em dashes' do
      smartify_hyphens('Text - more text!').should == "Text\u2014more text!"
    end
  end

  describe '#smartify_quotation_marks' do
    it 'converts initial inverted comma to a 9' do
      smartify_quotation_marks("More text in '78.").should == "More text in \u201978."
    end
    it 'converts inverted comma inside a word to a 9' do
      smartify_quotation_marks("Don't you forget about me.").should == "Don\u2019t you forget about me."
    end
    it 'converts ironic single quotes to 6 and 9' do
      smartify_quotation_marks("Text with 'ironic' quotes.").should == "Text with \u2018ironic\u2019 quotes."
    end
    it 'converts ironic single quotes to 6 and 9 even when it has abbreviations inside' do
      smartify_quotation_marks("Text 'I'm ironic' quotes.").should == "Text \u2018I\u2019m ironic\u2019 quotes."
    end
    it 'converts double quotes to 66 and 99' do
      smartify_quotation_marks("Text \"I'm ironic\" quotes.").should == "Text \u201CI\u2019m ironic\u201D quotes."
    end
  end

  describe '#smartify_numbers' do
    it 'changes exponents to <sup>' do
      smartify_numbers('1^2').should eq('1<sup>2</sup>')
    end
  end

  describe '#smartify' do
    pending 'Tests.'
  end

  describe '#bookify' do
    pending 'Tests.'
  end

  describe '#citation_partial' do
    pending 'Tests.'
  end

  describe '#clean_whitespace' do
    it 'replaces multiple new lines with a single new line' do
      clean_whitespace("Some text.\n\nMore text.").should  eq("Some text.\nMore text.")
    end
    it 'strips leading and trailing spaces' do
      clean_whitespace(' Text. More text.  ').should eq('Text. More text.')
    end
    it 'replaces extra whitespace with a single space' do
      clean_whitespace('Text.  More text.').should eq('Text. More text.')
    end
    it 'converts non-breaking spaces to ordinary spaces' do
      clean_whitespace('Some&nbsp;text').should eq('Some text')
    end
  end

  describe '#headerize' do
    it 'converts <strong> paragraphs to headers' do
      headerize("Plain text\n<strong>Header</strong>\nMore plain text")
        .should == "Plain text\n<header><h2>Header</h2></header>\nMore plain text"
    end
  end

  describe '#denumber_headers' do
    it 'removes numbers from headers' do
      denumber_headers("Plain text\n<header><h2>1. Header</h2></header>\nMore plain text")
        .should == "Plain text\n<header><h2>Header</h2></header>\nMore plain text"
    end
  end

  describe '#sectionize' do
    it 'wraps text under <h2> in a <section>' do
      sectionize("<header><h2>Header</h2></header>\nMore text\n<header><h2>Header</h2></header>\nMore text")
        .should == "<section><header><h2>Header</h2></header>\nMore text\n</section><section><header><h2>Header</h2></header>\nMore text</section>"
    end
  end

  describe '#paragraphize' do
    it 'wraps paragraphs in <p> tags' do
      paragraphize("Plain text\nMore plain text").should == "<p>Plain text</p>\n<p>More plain text</p>"
    end
    it 'wraps paragraphs in <p> tags even when they start with <strong>' do
      paragraphize("<strong>Plain</strong> text\nMore plain text")
        .should == "<p><strong>Plain</strong> text</p>\n<p>More plain text</p>"
    end
    it 'does not wrap headers in <p> tags' do
      paragraphize("Plain text\nMore plain text").should == "<p>Plain text</p>\n<p>More plain text</p>"
    end
    it 'does not wrap lists in <p> tags' do
      paragraphize("Plain text\nMore plain text").should == "<p>Plain text</p>\n<p>More plain text</p>"
    end
  end
end
