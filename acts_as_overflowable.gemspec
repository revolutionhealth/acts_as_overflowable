Gem::Specification.new do |s|
  s.name = %q{acts_as_overflowable}
  s.version = "2.0.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Revolution Health"]
  s.autorequire = %q{acts_as_overflowable}
  s.date = %q{2008-07-08}
  s.description = %q{A gem that allows a column to overflow data into a secondary column if the data size exceeds the character limit.  This is useful for fast indexing.}
  s.email = %q{rails@revolutionhealth.com}
  s.extra_rdoc_files = ["README", "TODO"]
  s.files = ["README", "Rakefile", "TODO", "lib/acts_as_overflowable.rb", "test/active_record_test_helper.rb", "test/test_helper.rb", "test/unit", "test/unit/acts_as_overflowable_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{A gem that allows a column to overflow data into a secondary column if the data size exceeds the character limit.  This is useful for fast indexing.}

  s.add_dependency(%q<activerecord>, ["~> 2.0"])
end
