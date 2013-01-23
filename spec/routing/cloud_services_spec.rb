describe "routing to update_cloud" do
  it "routes /auth/failure to cloud_services#auth_failure" do
    expect(:get => "/auth/failure").to route_to(
      :controller => "cloud_services",
      :action => "auth_failure"
    )
  end

  it "routes auth/:provider/callback to cloud_services#auth_callback" do
    expect(:get => "auth/PROVIDER/callback").to route_to(
      :controller => "cloud_services",
      :action => "auth_callback",
      :provider => "PROVIDER"
    )
  end

  it "does not expose all CRUD actions" do
    expect(:get => "/cloud_services/1/create").not_to be_routable
    expect(:get => "/cloud_services/show").not_to be_routable
    expect(:get => "/cloud_services/update").not_to be_routable
    expect(:get => "/cloud_services/edit").not_to be_routable
    expect(:get => "/cloud_services/new").not_to be_routable
    expect(:get => "/cloud_services/destroy").not_to be_routable
  end
end
