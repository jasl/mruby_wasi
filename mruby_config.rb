# frozen_string_literal: true

require "pathname"

WASI_SDK_PATH = Pathname.new(File.expand_path(ENV['WASI_SDK_PATH'] || fail('Specify WASI_SDK_PATH environment variable!')))
SYSROOT_PATH = WASI_SDK_PATH.join("share", "wasi-sysroot").realpath.to_s

CC = WASI_SDK_PATH.join("bin", "clang").realpath.to_s
CXX = WASI_SDK_PATH.join("bin", "clang++").realpath.to_s
AR = WASI_SDK_PATH.join("bin", "llvm-ar").realpath.to_s
LLD = WASI_SDK_PATH.join("bin", "clang").realpath.to_s

PROJECT_ROOT_PATH = Pathname.new(__dir__)
GEMBOX =
  if ENV["MRUBY_ENGINE_GEMBOX_PATH"] && File.exist?(ENV["MRUBY_ENGINE_GEMBOX_PATH"])
    fail "`#{ENV['MRUBY_ENGINE_GEMBOX_PATH']}` require `.gembox` extension" unless ENV["MRUBY_ENGINE_GEMBOX_PATH"].end_with?(".gembox")

    Pathname.new ENV["MRUBY_ENGINE_GEMBOX_PATH"][0..-8]
  else
    PROJECT_ROOT_PATH.join("mruby_engine")
  end

# https://github.com/mruby/mruby/blob/master/doc/guides/compile.md

MRuby::CrossBuild.new("wasm32-wasi") do |conf|
  toolchain :clang

  conf.gem "mruby-wasi-support"
  conf.gembox GEMBOX

  # Generate mruby commands
  conf.gem core: "mruby-bin-mruby"
  # conf.gem core: "mruby-bin-mrbc"
  # conf.gem core: "mruby-bin-mirb"

  # Turn on `enable_debug` for better debugging
#   conf.enable_debug
#   conf.enable_cxx_abi
#   conf.enable_test

  conf.exts do |exts|
    # exts.object = ".o"
    exts.executable = ".wasm"
    # exts.library = ".bc" # It's LLVM bit code
  end

  conf.asm do |as|
    as.command = cxx_abi_enabled? ? CXX : CC
    as.flags = ["-fno-integrated-as"]
  end

  conf.cc do |cc|
    cc.command = CC
    cc.flags = [
      "--sysroot=#{SYSROOT_PATH}",
      "-fPIC",
      "-m32",
      "-Wall",
      "-Wextra"
    ]
    cc.defines += %w[MRB_USE_DEBUG_HOOK MRB_UTF8_STRING MRB_WORD_BOXING]
    # cc.option_include_path = %q[-I"%s"]
    # cc.option_define = "-D%s"
    # cc.compile_options = %Q[%{flags} -MMD -o "%{outfile}" -c "%{infile}"]
  end

  conf.cxx do |cxx|
    cxx.command = CXX
    cxx.flags = [
      "--sysroot=#{SYSROOT_PATH}",
      "-fPIC",
      "-m32",
      "-Wall",
      "-Wextra"
    ]
    cc.defines += %w[MRB_USE_DEBUG_HOOK MRB_UTF8_STRING MRB_WORD_BOXING]
    # cxx.option_include_path = %q[-I"%s"]
    # cxx.option_define = "-D%s"
    # cxx.compile_options = %Q[%{flags} -MMD -o "%{outfile}" -c "%{infile}"]
  end

  conf.linker do |linker|
    linker.command = LLD
    linker.flags = %w[
      --verbose
      -m32
      -flto
    ]
#     linker.flags_before_libraries = []
    linker.libraries = %w[c clang_rt.builtins-wasm32]
#     linker.flags_after_libraries = []
    linker.library_paths = [
      WASI_SDK_PATH.join("share", "wasi-sysroot", "lib", "wasm32-wasi").to_s,
      WASI_SDK_PATH.join("lib", "clang", "13.0.0", "lib", "wasi").to_s
    ]
#     linker.option_library = '-l%s'
#     linker.option_library_path = '-L%s'
#     linker.link_options = "%{flags} -o '%{outfile}' '#{WASI_SDK_PATH}/share/wasi-sysroot/lib/wasm32-wasi/crt1.o' %{objs} %{libs}"
  end

  conf.archiver do |archiver|
    archiver.command = AR
    # archiver.archive_options = 'vrs "%{outfile}" %{objs}'
  end

  conf.test_runner do |t|
    t.command = 'wasmtime'
  end

#   conf.cc do |cc|
#     cc.flags += %w[-fPIC]
#     cc.flags += Flags.wasm32_cflags
#     cc.defines += Flags.wasm32_defines
#   end
#
#   conf.linker do |linker|
#     linker.flags += Flags.wasm32_linker_flags
#     # linker.library_paths += Flags.library_paths
#   end
end
