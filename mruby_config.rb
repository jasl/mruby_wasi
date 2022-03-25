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

ASYNCIFY = ENV["ASYNCIFY"].to_i == 1

# https://github.com/mruby/mruby/blob/master/doc/guides/compile.md

MRuby::CrossBuild.new("wasm32-unknown-wasi") do |conf|
  toolchain :clang

  conf.gembox GEMBOX

  if ASYNCIFY
    conf.gem "mruby-wasi-asyncify-compilable"
  else
    conf.gem "mruby-wasi-compilable"
  end

  # Generate mruby commands
  conf.gem core: "mruby-bin-mruby"
  # conf.gem core: "mruby-bin-mirb"

  # Turn on `enable_debug` for better debugging
  conf.enable_debug
  # conf.enable_test

  conf.cc do |cc|
    cc.command = cxx_abi_enabled? ? CXX : CC
    cc.flags += [
      "--sysroot=#{SYSROOT_PATH}",
      "--target=wasm32-wasi",
      "-m32",
      # "-flto",
    ]
    cc.defines += %w[
      MRB_USE_DEBUG_HOOK
      MRB_UTF8_STRING
      MRB_WORD_BOXING
      MRB_WORDBOX_NO_FLOAT_TRUNCATE
      MRB_USE_RO_DATA_P_ETEXT
    ]
  end

  # # WASI doesn't support C++ exception yet, so this can't enable
  # conf.enable_cxx_abi
  # conf.cxx do |cxx|
  #   cxx.command = CXX
  #   cxx.flags += [
  #     "--sysroot=#{SYSROOT_PATH}",
  #     "--target=wasm32-wasi",
  #     "-m32",
  #     # "-flto",
  #   ]
  #   cxx.defines += %w[
  #     MRB_USE_DEBUG_HOOK
  #     MRB_UTF8_STRING
  #     MRB_WORD_BOXING
  #     MRB_WORDBOX_NO_FLOAT_TRUNCATE
  #     MRB_USE_RO_DATA_P_ETEXT
  #   ]
  # end

  conf.asm do |as|
    as.command = cxx_abi_enabled? ? CXX : CC
    as.flags += ["--target=wasm32-wasi"]
    cc.defines += %w[
      MRB_USE_DEBUG_HOOK
      MRB_UTF8_STRING
      MRB_WORD_BOXING
      MRB_WORDBOX_NO_FLOAT_TRUNCATE
      MRB_USE_RO_DATA_P_ETEXT
    ]
  end

  conf.linker do |linker|
    linker.command = LLD
    linker.flags += [
      # "-Wl,--lto-O3",
      "--verbose",
    ]
  end

  conf.archiver do |archiver|
    archiver.command = AR
  end

  conf.exts.executable = ".wasm"

  conf.test_runner do |t|
    t.command = 'wasmtime'
  end

  puts "================================================"
  puts "CC flags"
  puts conf.cc.flags.compact.join(", ")
  puts "CC Defines"
  puts conf.cc.defines.compact.join(", ")

  puts "CXX flags"
  puts conf.cxx.flags.compact.join(", ")
  puts "CXX Defines"
  puts conf.cxx.defines.compact.join(", ")

  puts "ASM flags"
  puts conf.asm.flags.compact.join(", ")
  puts "ASM Defines"
  puts conf.asm.defines.compact.join(", ")

  puts "Linker flags"
  puts conf.linker.flags.compact.join(", ")
  puts "================================================"
end
