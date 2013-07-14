# encoding: utf-8

describe 'routing to bibliography' do
  it 'routes /bibliography to book#index' do
    expect(get: '/bibliography').to route_to(
      controller: 'books',
      action: 'index'
    )
  end

  it 'routes /bibliography/:slug to book#show for slug' do
    expect(get: '/bibliography/mybook123').to route_to(
      controller: 'books',
      action: 'show',
      slug: 'mybook123'
    )
  end

  it 'routes hyphenated slugs' do
    expect(get: '/bibliography/my-book').to route_to(
      controller: 'books',
      action: 'show',
      slug: 'my-book'
    )
  end

  it 'only routes valid book names' do
    expect(get: '/bibliography/my,book').not_to be_routable
    expect(get: '/bibliography/my!book').not_to be_routable
    expect(get: '/bibliography/my book').not_to be_routable
  end
end
