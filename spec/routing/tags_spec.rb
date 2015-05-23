# encoding: utf-8

RSpec.describe 'routing to tags' do
  it 'routes /tags to tag#index' do
    expect(get: '/tags').to route_to(
      controller: 'tags',
      action: 'index'
    )
  end

  it 'routes /tags/:slug to tag#show for slug' do
    expect(get: '/tags/mytag123').to route_to(
      controller: 'tags',
      action: 'show',
      slug: 'mytag123'
    )
  end

  it 'routes hyphenated slugs' do
    expect(get: '/tags/my-tag').to route_to(
      controller: 'tags',
      action: 'show',
      slug: 'my-tag'
    )
  end

  it 'only routes valid tag names' do
    expect(get: '/tags/my,tag').not_to be_routable
    expect(get: '/tags/my!tag').not_to be_routable
    expect(get: '/tags/my tag').not_to be_routable
  end
end
