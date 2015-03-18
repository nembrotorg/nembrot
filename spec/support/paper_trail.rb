RSpec.configure do |config|
  config.before(:example) do
    PaperTrail.enabled = false
  end

  config.before(:example, versioning: true) do
    PaperTrail.enabled = true
  end
end
