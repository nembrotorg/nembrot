# encoding: utf-8

RSpec.describe 'routing to evernote_notes' do
  it 'routes /webhooks/evernote_note to evernote_notes#add_task' do
    expect(get: '/webhooks/evernote_note').to route_to(
      controller: 'evernote_notes',
      action: 'add_task'
    )
  end

  it 'does not expose all CRUD actions' do
    expect(get: '/evernote_notes/1/create').not_to be_routable
    # pending "expect(get: '/evernote_notes/show').to route_to(root_path)"
    # pending "expect(get: '/evernote_notes/update').to route_to(root_path)"
    # pending "expect(get: '/evernote_notes/edit').to route_to(root_path)"
    # pending "expect(get: '/evernote_notes/new').to route_to(root_path)"
    # pending "expect(get: '/evernote_notes/destroy').to route_to(root_path)"
  end
end
