describe "routing to evernote_auths" do

  it "routes /auth/failure to evernote_auths#auth_failure" do
    expect(:get => "/auth/failure").to route_to(
      :controller => "evernote_auths",
      :action => "auth_failure"
    )
  end

  it "routes auth/:provider/callback to evernote_auths#auth_callback" do
    expect(:get => "auth/PROVIDER/callback").to route_to(
      :controller => "evernote_auths",
      :action => "auth_callback",
      :provider => "PROVIDER"
    )
  end

  it "does not expose all CRUD actions" do
    expect(:get => "/evernote_auths/1/create").not_to be_routable
    expect(:get => "/evernote_auths/show").not_to be_routable
    expect(:get => "/evernote_auths/update").not_to be_routable
    expect(:get => "/evernote_auths/edit").not_to be_routable
    expect(:get => "/evernote_auths/new").not_to be_routable
    expect(:get => "/evernote_auths/destroy").not_to be_routable
  end
end
