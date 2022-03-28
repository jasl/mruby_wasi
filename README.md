Mr.Engifar
====

## Requirements

- CRuby 2.6+
- https://github.com/WebAssembly/wasi-sdk
- https://github.com/WebAssembly/binaryen

## Build

### WASI

> Because of WASI lacking exception-handling or setjmp/longjmp support, it's unusable at this time.

- You must set `WASI_SDK_PATH` env
  - e.g. `export WASI_SDK_PATH="~/opt/wasi-sdk-14.0"`
- You may need run `rake mrproper` before switching build

#### Build with `Asyncify`

> It's broken, because I'm not understand how to integrate Asyncify

Build mruby

`ASYNCIFY=1 rake`

Run `wasm-opt` (from Binaryen)

`wasm-opt -g --asyncify -O3 --pass-arg=asyncify-ignore-imports -o bin/mruby.wasm mruby/build/wasm32-unknown-wasi/bin/mruby.wasm`

> Disable optimization may get error `Invalid input WebAssembly code at offset 2464055: locals exceed`

### Build without `Asyncify`

> It's only stubbed `setjmp & longjmp` so it will crash when Ruby's exception raised

`rake`

## Play

TODO

## References

- https://eng-blog.iij.ad.jp/archives/10875
- https://itnext.io/final-report-webassembly-wasi-support-in-ruby-4aface7d90c9
  - https://github.com/Ruby/Ruby/pull/5407
  - https://github.com/ruby/ruby/tree/master/wasm
- https://kripken.github.io/blog/wasm/2019/07/16/asyncify.html
  - https://github.com/kripken/talks/blob/master/jmp.c

## License

Mr.Engifar is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
