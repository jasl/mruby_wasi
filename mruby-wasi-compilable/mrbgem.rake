MRuby::Gem::Specification.new('mruby-wasi-compilable') do |spec|
  spec.license = 'MIT'
  spec.authors = ['mruby developers']
  spec.summary = 'Make mruby compilable on WASI with stubbed not support functions'

  spec.add_conflict "mruby-wasi-asyncify-compilable"

  spec.build.cc.include_paths << "#{File.expand_path(__dir__)}/include"
end
