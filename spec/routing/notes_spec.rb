# encoding: utf-8

describe 'routing to notes' do
  it 'routes /texts to note#index' do
    expect(get: '/texts').to route_to(
      controller: 'notes',
      action: 'index'
    )
  end

  it 'routes /texts/:id to note#show for id' do
    expect(get: '/texts/1').to route_to(
      controller: 'notes',
      action: 'show',
      id: '1'
    )
  end

  it 'routes /texts/:id/v/:sequence to note#version for id, sequqence' do
    expect(get: '/texts/1/v/1').to route_to(
      controller: 'notes',
      action: 'version',
      id: '1',
      sequence: '1'
    )
  end

  it 'does not expose all CRUD actions' do
    expect(get: '/texts/1/create').not_to be_routable
    pending "expect(get: '/texts/show').to route_to(root_path)"
    pending "expect(get: '/texts/update').to route_to(root_path)"
    pending "expect(get: '/texts/edit').to route_to(root_path)"
    pending "expect(get: '/texts/new').to route_to(root_path)"
    pending "expect(get: '/texts/destroy').to route_to(root_path)"
  end

  it 'requires a numerical id' do
    pending"expect(get: '/texts/abc').to route_to(root_path)"
  end

  it 'requires a numerical sequence' do
    expect(get: '/texts/1/v/abc').not_to be_routable
  end
end
