RSpec.configure do |config|
  config.before(:each) do
    PaperTrail.enabled = true # REVIEW: This should be set to false but the test below is not working
  end

  config.before(:each, versioning: true) do
    PaperTrail.enabled = true
  end
end
