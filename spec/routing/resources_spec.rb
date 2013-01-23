describe "routing to resources" do

  it "routes /resources/cut to resources#cut" do
    expect(:get => "/resources/cut/FILENAME-100-200-300.png").to route_to(
      :controller => "resources",
      :action => "cut",
      :file_name => 'FILENAME',
      :aspect_x => '100',
      :aspect_y => '200',
      :width => '300',
      :format => 'png'
    )
  end

  it "does not expose all CRUD actions" do
    expect(:get => "/resources/1/create").not_to be_routable
    expect(:get => "/resources/show").not_to be_routable
    expect(:get => "/resources/update").not_to be_routable
    expect(:get => "/resources/edit").not_to be_routable
    expect(:get => "/resources/new").not_to be_routable
    expect(:get => "/resources/destroy").not_to be_routable
  end

  it "requires numerical dimensions" do
    expect(:get => "/resources/cut/FILENAME-A10-200-300.png").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-B20-300.png").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-200-C30.png").not_to be_routable
  end

  it "requires a graphic format" do
    expect(:get => "/resources/cut/FILENAME-100-200-300.css").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-200-300.html").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-200-300.js").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-200-300.json").not_to be_routable
    expect(:get => "/resources/cut/FILENAME-100-200-300.xml").not_to be_routable
  end
end
