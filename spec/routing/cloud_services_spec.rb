describe "routing to update_cloud" do
  it "routes /webhooks/evernote_note to cloud_notes#update_cloud" do
    expect(:get => "/webhooks/evernote_note").to route_to(
      :controller => "cloud_notes",
      :action => "update_cloud"
    )
  end

  it "does not expose all CRUD actions" do
    expect(:get => "/update_cloud/1/create").not_to be_routable
    expect(:get => "/update_cloud/show").not_to be_routable
    expect(:get => "/update_cloud/update").not_to be_routable
    expect(:get => "/update_cloud/edit").not_to be_routable
    expect(:get => "/update_cloud/new").not_to be_routable
    expect(:get => "/update_cloud/destroy").not_to be_routable
  end
end
