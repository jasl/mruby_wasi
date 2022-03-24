MRuby::Gem::Specification.new('mruby-wasi-stub') do |spec|
  spec.license = 'MIT'
  spec.authors = ['mruby developers']
  spec.summary = 'Make mruby compilable on WASI'

  spec.build.cc.include_paths << "#{File.expand_path(__dir__)}/include"
end
