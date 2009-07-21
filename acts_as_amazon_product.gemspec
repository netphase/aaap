# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_amazon_product}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Nedderman", "Chris Beck"]
  s.date = %q{2009-06-18}
  s.email = %q{scott@netphase.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "COPYING",
     "README",
     "Rakefile",
     "VERSION",
     "acts_as_amazon_product.gemspec",
     "generators/acts_as_amazon_product_migration/acts_as_amazon_product_migration_generator.rb",
     "generators/acts_as_amazon_product_migration/templates/migration.rb",
     "init.rb",
     "install.rb",
     "lib/acts_as_amazon_product.rb",
     "lib/amazon_product.rb",
     "tasks/acts_as_amazon_product_tasks.rake",
     "test/acts_as_amazon_product_test.rb",
     "test/config-example.yml",
     "test/example.rb",
     "uninstall.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/netphase/aaap}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A package for simplifying use of the Amazon/ECS API}
  s.test_files = [
    "test/acts_as_amazon_product_test.rb",
     "test/example.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amazon-ecs>, [">= 0.5.1"])
    else
      s.add_dependency(%q<amazon-ecs>, [">= 0.5.1"])
    end
  else
    s.add_dependency(%q<amazon-ecs>, [">= 0.5.1"])
  end
end
