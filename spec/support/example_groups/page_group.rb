shared_examples_for 'a page' do

  it 'has no missing translations' do
    expect(page).to have_css('ul li a[xxxx]')
  end

end
