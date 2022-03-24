mruby WASI
====

## Requirements

- https://github.com/WebAssembly/wasi-sdk
- https://github.com/WebAssembly/binaryen

## Compile

`rake`
`wasm-opt -g --asyncify -O3 --pass-arg=asyncify-ignore-imports -o bin/mruby.wasm mruby/build/wasm32-wasi/bin/mruby.wasm`

## Play

`wasmtime run bin/mruby.wasm -- -e 'puts "Hello, mruby on WASI!"'`

## References

- https://eng-blog.iij.ad.jp/archives/10875
- https://github.com/ruby/ruby/tree/master/wasm

## License

mruby engine is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
