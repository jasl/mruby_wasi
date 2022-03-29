# frozen_string_literal: true

require 'mkmf'

CC = find_executable("emcc")
fail "`emcc` not found" unless CC

CXX = find_executable("em++")
fail "`em++` not found" unless CXX

AR = find_executable("emar")
fail "`emar` not found" unless AR

PROJECT_ROOT_PATH = Pathname.new(__dir__).parent
GEMBOX =
  if ENV["MRUBY_ENGINE_GEMBOX_PATH"] && File.exist?(ENV["MRUBY_ENGINE_GEMBOX_PATH"])
    fail "`#{ENV['MRUBY_ENGINE_GEMBOX_PATH']}` require `.gembox` extension" unless ENV["MRUBY_ENGINE_GEMBOX_PATH"].end_with?(".gembox")

    Pathname.new ENV["MRUBY_ENGINE_GEMBOX_PATH"][0..-8]
  else
    PROJECT_ROOT_PATH.join("mruby_engine")
  end

PRODUCTION = ENV["PRODUCTION"].to_i == 1

SHARD_COMPILER_FLAGS = [
  "-fexceptions",
  # "-fwasm-exceptions", # Use WASM EH, but most of VM not support it ATM
  "-m32",
]

SHARD_OPTIMIZATION_COMPILER_FLAGS = [
  # "-flto",
]

CC_COMPILER_FLAGS = [
  # "--std=c99",
]

CXX_COMPILER_FLAGS = [
  # "--std=c++11",
]

SHARD_COMPILER_DEFINES = %w[
  MRB_USE_DEBUG_HOOK
  MRB_UTF8_STRING
  MRB_WORD_BOXING
  MRB_WORDBOX_NO_FLOAT_TRUNCATE
  MRB_USE_RO_DATA_P_ETEXT
  MRB_GC_TURN_OFF_GENERATIONAL
]

LINKER_FLAGS = [
  "-fexceptions",
  # "-fwasm-exceptions", # Use WASM EH, but most of VM not support it ATM
  "-m32"
]

OPTIMIZATION_LINKER_FLAGS = []

# https://github.com/mruby/mruby/blob/master/doc/guides/compile.md

MRuby::CrossBuild.new("wasm32-emscripten") do |conf|
  toolchain :clang

  conf.gembox GEMBOX

  # TODO: Remove this
  conf.gem core: "mruby-bin-mruby"

  conf.enable_debug unless PRODUCTION

  conf.cc do |cc|
    cc.command = cxx_abi_enabled? ? CXX : CC
    cc.flags += SHARD_COMPILER_FLAGS
    cc.flags += SHARD_OPTIMIZATION_COMPILER_FLAGS unless debug_enabled?
    cc.flags += CC_COMPILER_FLAGS
    cc.defines += SHARD_COMPILER_DEFINES
  end

  conf.enable_cxx_abi
  conf.cxx do |cxx|
    cxx.command = CXX
    cxx.flags += SHARD_COMPILER_FLAGS
    cxx.flags += SHARD_OPTIMIZATION_COMPILER_FLAGS unless debug_enabled?
    cxx.flags += CXX_COMPILER_FLAGS
    cxx.defines += SHARD_COMPILER_DEFINES
  end

  conf.asm do |as|
    as.command = cxx_abi_enabled? ? CXX : CC
    as.flags += SHARD_COMPILER_FLAGS
    as.flags += SHARD_OPTIMIZATION_COMPILER_FLAGS unless debug_enabled?
    as.defines += SHARD_COMPILER_FLAGS
  end

  conf.linker do |linker|
    linker.command = cxx_abi_enabled? ? CXX : CC
    linker.flags += LINKER_FLAGS
    linker.flags += OPTIMIZATION_LINKER_FLAGS unless debug_enabled?
  end

  conf.archiver do |archiver|
    archiver.command = AR
  end

  conf.exts.executable = ".wasm"

  conf.test_runner do |t|
    t.command = 'wasmtime'
  end

  puts "================================================"
  puts "Emscripten build config"
  puts "================================================"
  puts "CC flags:"
  puts conf.cc.flags.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts
  puts "CC defines:"
  puts conf.cc.defines.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts

  puts "CXX flags:"
  puts conf.cxx.flags.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts
  puts "CXX defines:"
  puts conf.cxx.defines.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts

  puts "ASM flags:"
  puts conf.asm.flags.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts
  puts "ASM defines:"
  puts conf.asm.defines.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts

  puts "Linker flags:"
  puts conf.linker.flags.flatten.reject { |s| s.to_s.size.zero? }.join(", ")
  puts "================================================"
end
