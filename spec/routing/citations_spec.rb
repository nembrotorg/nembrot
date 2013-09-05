# encoding: utf-8

describe 'routing to citations' do
  it 'routes /citations to citation#index' do
    expect(get: '/citations').to route_to(
      controller: 'citations',
      action: 'index'
    )
  end

  it 'routes /citations/:id to citation#show for id' do
    expect(get: '/citations/1').to route_to(
      controller: 'citations',
      action: 'show',
      id: '1'
    )
  end

  it 'does not expose all CRUD actions' do
    expect(get: '/citations/1/create').not_to be_routable
    expect(get: '/citations/show').not_to be_routable
    expect(get: '/citations/update').not_to be_routable
    expect(get: '/citations/edit').not_to be_routable
    expect(get: '/citations/new').not_to be_routable
    expect(get: '/citations/destroy').not_to be_routable
  end

  it 'requires a numerical id' do
    expect(get: '/citations/abc').not_to be_routable
  end
end
