# encoding: utf-8

describe 'routing to evernote_notes' do
  it 'routes /webhooks/evernote_note to evernote_notes#add_task' do
    expect(get: '/webhooks/evernote_note').to route_to(
      controller: 'evernote_notes',
      action: 'add_task'
    )
  end

  it 'does not expose all CRUD actions' do
    expect(get: '/evernote_notes/1/create').not_to be_routable
    expect(get: '/evernote_notes/show').not_to be_routable
    expect(get: '/evernote_notes/update').not_to be_routable
    expect(get: '/evernote_notes/edit').not_to be_routable
    expect(get: '/evernote_notes/new').not_to be_routable
    expect(get: '/evernote_notes/destroy').not_to be_routable
  end
end
