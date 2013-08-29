RSpec.configure do |config|
  config.before(:each) do
    PaperTrail.enabled = false
  end

  config.before(:each, versioning: true) do
    PaperTrail.enabled = true
  end
end
