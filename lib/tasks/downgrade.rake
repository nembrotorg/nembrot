namespace :downgrades do

  desc 'Send downgrade warnings and downgrade'

  task audit: :environment do |t, args|
    User.audit_downgrade_warnings
    User.audit_downgrades
  end
end
