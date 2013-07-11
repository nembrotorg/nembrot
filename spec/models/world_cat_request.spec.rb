# encoding: utf-8

describe WorldCatRequest do

  context 'when a book is found:' do
    before do
      @world_cat_book = WorldCatRequest.new('0804720991')
    end

    subject { @world_cat_book.metadata }

    its (['editor']) { should == '' }
    its (['introducer']) { should == '' }
    its (['published_date']) { should == '1-1-1990' }
    its (['publisher']) { should == 'Stanford University Press' }
    its (['translator']) { should == '' }
  end

  context 'when a book is not found:' do
    before do
      @world_cat_book_nil = WorldCatRequest.new('INVALID_ISBN')
    end

    # TODO: This fails!
    pending 'its (:metadata) { should == nil }'
  end
end
