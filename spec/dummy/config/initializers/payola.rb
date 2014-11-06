require 'sucker_punch'

Payola.configure do |payola|

  payola.secret_key = 'sk_test_TYtgGt8qBaUpEJh0ZIY1jUuO'
  payola.publishable_key = 'pk_test_KeUPeR6mUmS67g2YdJ9nhqBF'

  payola.background_worker = :sucker_punch
end
