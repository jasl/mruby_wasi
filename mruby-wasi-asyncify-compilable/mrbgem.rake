MRuby::Gem::Specification.new('mruby-wasi-asyncify-compilable') do |spec|
  spec.license = 'MIT'
  spec.authors = ['mruby developers']
  spec.summary = 'Make mruby compilable on WASI with Asyncify enabled'

  spec.add_conflict "mruby-wasi-compilable"

  spec.build.cc.include_paths << "#{File.expand_path(__dir__)}/include"
  spec.cc.include_paths << "#{build.root}/src"
end
