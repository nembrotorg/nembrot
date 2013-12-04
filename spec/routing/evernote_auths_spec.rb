# encoding: utf-8

describe 'routing to evernote_auths' do

  it 'routes /auth/failure to evernote_auths#auth_failure' do
    expect(get: '/auth/failure').to route_to(
      controller: 'evernote_auths',
      action: 'auth_failure'
    )
  end

  it 'routes auth/:provider/callback to evernote_auths#auth_callback' do
    expect(get: 'auth/PROVIDER/callback').to route_to(
      controller: 'evernote_auths',
      action: 'auth_callback',
      provider: 'PROVIDER'
    )
  end

  it 'does not expose all CRUD actions' do
    expect(get: '/evernote_auths/1/create').not_to be_routable
    pending "expect(get: '/evernote_auths/show').to route_to(root_path)"
    pending "expect(get: '/evernote_auths/update').to route_to(root_path)"
    pending "expect(get: '/evernote_auths/edit').to route_to(root_path)"
    pending "expect(get: '/evernote_auths/new').to route_to(root_path)"
    pending "expect(get: '/evernote_auths/destroy').to route_to(root_path)"
  end
end
