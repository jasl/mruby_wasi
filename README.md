mruby WASI
====

## Requirements

- CRuby 2.6+
- https://github.com/WebAssembly/wasi-sdk
- https://github.com/WebAssembly/binaryen

## Build

- You must set `WASI_SDK_PATH` env
  - e.g. `export WASI_SDK_PATH="~/opt/wasi-sdk-14.0"`
- You may need run `rake mrproper` before switching build
- Don't forget `git submodule update --init` to fetch submodules

### Build with `Asyncify`

Build mruby

`ASYNCIFY=1 rake`

Run `wasm-opt` (from Binaryen)

`wasm-opt -g --asyncify -O3 --pass-arg=asyncify-ignore-imports -o bin/mruby.wasm mruby/build/wasm32-unknown-wasi/bin/mruby.wasm`

> Disable optimization may get error `Invalid input WebAssembly code at offset 2464055: locals exceed`

### Build without `Asyncify`

> Ruby's exception will lead crash

`rake`

## Play

> First time run may take minutes

### if build with `Asyncify`

> TODO: Weird there's no output

`wasmtime run bin/mruby.wasm -- -e 'puts "Hello, mruby on WASI!"'`

### if build without `Asyncify`

> TODO: Copy executable to `bin` folder

`wasmtime run mruby/build/wasm32-unknown-wasi/bin/mruby.wasm -- -e 'puts "Hello, mruby on WASI!"'`

## Limitation

- `enable_cxx_exception` will fail because WASI lacking C++ exception support

## Debugging

See https://docs.wasmtime.dev/examples-debugging.html

## References

- https://eng-blog.iij.ad.jp/archives/10875
- https://itnext.io/final-report-webassembly-wasi-support-in-ruby-4aface7d90c9
  - https://github.com/ruby/ruby/tree/master/wasm
- https://github.com/kripken/talks/blob/master/jmp.c

## License

mruby engine is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
