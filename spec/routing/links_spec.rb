# encoding: utf-8

describe 'routing to links' do
  it 'routes /links/admin to link#admin' do
    expect(get: '/links/admin').to route_to(
      controller: 'links',
      action: 'admin'
    )
  end

  it 'routes /links/admin to link#admin' do
    expect(get: '/links/admin').to route_to(
      controller: 'links',
      action: 'admin'
    )
  end

  it 'routes /links/1/edit to link#edit?id=1' do
    expect(get: '/links/1/edit').to route_to(
      controller: 'links',
      action: 'edit',
      id: '1'
    )
  end
end
