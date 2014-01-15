# encoding: utf-8

describe 'routing to tags' do
  it 'routes /channel-slug/tags to tag#index' do
    expect(get: '/channel-slug/tags').to route_to(
      controller: 'tags',
      action: 'index',
      channel: 'channel-slug'
    )
  end

  it 'routes /channel-slug/tags/:slug to tag#show for slug' do
    expect(get: '/channel-slug/tags/mytag123').to route_to(
      controller: 'tags',
      action: 'show',
      channel: 'channel-slug',
      slug: 'mytag123'
    )
  end

  it 'routes hyphenated slugs' do
    expect(get: '/channel-slug/tags/my-tag').to route_to(
      controller: 'tags',
      action: 'show',
      channel: 'channel-slug',
      slug: 'my-tag'
    )
  end

  it 'only routes valid tag names' do
    expect(get: '/channel-slug/tags/my,tag').not_to be_routable
    expect(get: '/channel-slug/tags/my!tag').not_to be_routable
    expect(get: '/channel-slug/tags/my tag').not_to be_routable
  end
end
