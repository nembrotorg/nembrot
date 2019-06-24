# encoding: utf-8

RSpec.describe 'routing to citations' do
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
    # pending "expect(get: '/citations/show').to route_to(root_path)"
    # pending "expect(get: '/citations/update').to route_to(root_path)"
    # pending "expect(get: '/citations/edit').to route_to(root_path)"
    # pending "expect(get: '/citations/new').to route_to(root_path)"
    # pending "expect(get: '/citations/destroy').to route_to(root_path)"
  end

  it 'requires a numerical id' do
    # pending "expect(get: '/citations/abc').to route_to(root_path)"
  end
end
