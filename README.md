mruby WASI
====

## Requirements

- CRuby 2.6+
- https://github.com/WebAssembly/wasi-sdk
- https://github.com/WebAssembly/binaryen

## Compile

**Note: You need `rake mrproper` before switch build**

### build with `Asyncify`

`ASYNCIFY=1 rake`

`wasm-opt -g --asyncify -O3 --pass-arg=asyncify-ignore-imports -o bin/mruby.wasm mruby/build/wasm32-unknown-wasi/bin/mruby.wasm`

### not build with `Asyncify`

> Ruby's exception will lead crash

`ASYNCIFY=1 rake`

## Play

### if build with `Asyncify`

> Weird no output

`wasmtime run bin/mruby.wasm -- -e 'puts "Hello, mruby on WASI!"'`

### if build without `Asyncify`

> TODO: Copy executable to `bin` folder

`wasmtime run mruby/build/wasm32-unknown-wasi/bin/mruby.wasm -- -e 'puts "Hello, mruby on WASI!"'`

## Limitation

- `enable_cxx_abi` will fail because WASI lacking C++ exception support

## References

- https://eng-blog.iij.ad.jp/archives/10875
- https://github.com/ruby/ruby/tree/master/wasm

## License

mruby engine is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
