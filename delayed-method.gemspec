Gem::Specification.new do |s|
  s.name              = "delayed-method"
  s.version           = "0.1.0"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Allow you to quickly move a long call to background which then executed by resque"
  s.homepage          = "http://github.com/phuongnd08/delayed-method"
  s.email             = "phuongnd08@gmail"
  s.authors           = [ "Phuong Nguyen" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.add_dependency    "resque"
  s.add_dependency    "activesupport"
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "debugger"
  s.add_development_dependency "activerecord"

  s.description = "Allow you to quickly move a long call to background which then executed by resque"
end
