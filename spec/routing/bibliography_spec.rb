# encoding: utf-8

describe 'routing to bibliography' do
  it 'routes /:channel/bibliography to book#index' do
    expect(get: '/channel-slug/bibliography').to route_to(
      controller: 'books',
      action: 'index',
      channel: 'channel-slug'
    )
  end

  it 'routes /:channel/bibliography/:slug to book#show for slug' do
    expect(get: '/channel-slug/bibliography/mybook123').to route_to(
      controller: 'books',
      action: 'show',
      channel: 'channel-slug',
      slug: 'mybook123'
    )
  end

  it 'routes hyphenated slugs' do
    expect(get: '/channel-slug/bibliography/my-book').to route_to(
      controller: 'books',
      action: 'show',
      channel: 'channel-slug',
      slug: 'my-book'
    )
  end

  it 'only routes valid book names' do
    expect(get: '/channel-slug/bibliography/my,book').not_to be_routable
    expect(get: '/channel-slug/bibliography/my!book').not_to be_routable
    expect(get: '/channel-slug/bibliography/my book').not_to be_routable
  end

  it 'routes /:channel/bibliography/admin to book#admin' do
    expect(get: '/channel-slug/bibliography/admin').to route_to(
      controller: 'books',
      action: 'admin',
      channel: 'channel-slug'
    )
  end

  it 'routes /:channel/bibliography/admin/cited to book#admin?mode=cited' do
    expect(get: '/channel-slug/bibliography/admin/cited').to route_to(
      controller: 'books',
      action: 'admin',
      channel: 'channel-slug',
      mode: 'cited'
    )
  end

  it 'routes /:channel/bibliography/1/edit to book#edit?id=1' do
    expect(get: '/channel-slug/bibliography/1/edit').to route_to(
      controller: 'books',
      action: 'edit',
      channel: 'channel-slug',
      id: '1'
    )
  end
end
