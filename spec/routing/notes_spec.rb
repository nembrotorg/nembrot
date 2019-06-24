# encoding: utf-8

RSpec.describe 'routing to notes' do
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

  # it 'does not expose all CRUD actions' do
  #   expect(get: '/texts/1/create').not_to be_routable
  #   expect(get: '/texts/show').not_to be_routable
  #   expect(get: '/texts/update').not_to be_routable
  #   expect(get: '/texts/edit').not_to be_routable
  #   expect(get: '/texts/new').not_to be_routable
  #   expect(get: '/texts/destroy').not_to be_routable
  # end

  # it 'requires a numerical id' do
  #   expect(get: '/texts/abc').not_to be_routable
  # end

  it 'requires a numerical sequence' do
    expect(get: '/texts/1/v/abc').not_to be_routable
  end
end
