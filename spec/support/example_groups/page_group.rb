shared_examples_for "a page" do

  it 'has no missing translations' do
    page.should have_css('ul li a[xxxx]')
  end

end