describe "routing to update_cloud" do
  it "routes /webhooks/evernote_note to cloud_notes#update_cloud" do
    expect(:get => "/webhooks/evernote_note").to route_to(
      :controller => "cloud_notes",
      :action => "update_cloud"
    )
  end

  it "does not expose all CRUD actions" do
    expect(:get => "/cloud_notes/1/create").not_to be_routable
    expect(:get => "/cloud_notes/show").not_to be_routable
    expect(:get => "/cloud_notes/update").not_to be_routable
    expect(:get => "/cloud_notes/edit").not_to be_routable
    expect(:get => "/cloud_notes/new").not_to be_routable
    expect(:get => "/cloud_notes/destroy").not_to be_routable
  end
end
