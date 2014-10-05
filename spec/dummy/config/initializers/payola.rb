require 'sucker_punch'

Payola.configure do |payola|
  payola.background_worker = :sucker_punch
end
