MRuby::Gem::Specification.new('mruby-wasi-build-pack') do |spec|
  spec.license = 'MIT'
  spec.authors = ['mruby developers']
  spec.summary = 'Make mruby compilable on WASI with stubbed not supported functions'

  spec.add_conflict "mruby-wasi-asyncify-build-pack"

  spec.build.cc.include_paths << "#{File.expand_path(__dir__)}/include"
end
