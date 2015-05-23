# encoding: utf-8

RSpec.describe 'routing to bibliography' do
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

  it 'routes /bibliography/admin to book#admin' do
    expect(get: '/bibliography/admin').to route_to(
      controller: 'books',
      action: 'admin'
    )
  end

  it 'routes /bibliography/admin/cited to book#admin?mode=cited' do
    expect(get: '/bibliography/admin/cited').to route_to(
      controller: 'books',
      action: 'admin',
      mode: 'cited'
    )
  end

  it 'routes /bibliography/1/edit to book#edit?id=1' do
    expect(get: '/bibliography/1/edit').to route_to(
      controller: 'books',
      action: 'edit',
      id: '1'
    )
  end
end
