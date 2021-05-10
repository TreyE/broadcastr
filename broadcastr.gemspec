# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'broadcastr'
  s.version     = '0.1.0'
  s.summary     = "Broadcastr: Does Events"
  s.description = "A gem for simplified AMQP broadcast and subscription of events."
  s.authors     = ["Trey Evans"]
  s.files       = `git ls-files -z`.split("\x0")
  s.require_paths = ["lib"]
  s.license     = 'MIT'

  s.add_dependency "activesupport", "> 4.2.0"
  s.add_dependency "sneakers"
  s.add_dependency "serverengine"
end
