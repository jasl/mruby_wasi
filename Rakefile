# frozen_string_literal: true

require "pathname"
require "fileutils"

MRUBY_DIR = Pathname.new(__dir__).join("mruby")
raise(<<-MESSAGE) unless Dir.exist?(MRUBY_DIR.join("src"))

  The mruby source code appears to be missing. Did you clone this gem with
  submodules? If that is not the case or you are unsure, you can run the
  following commands:

    $ git submodule init
    $ git submodule update

MESSAGE

PROJECT_ROOT = Pathname.new(__dir__)

SUPPORTED_WASM_TARGETS = %w[wasi emscripten]
WASM_TARGET =
  if ENV["WASM_TARGET"]
    if SUPPORTED_WASM_TARGETS.include? ENV["WASM_TARGET"].downcase
      ENV["WASM_TARGET"].downcase
    else
      fail "Unknown WASM target: `#{ENV["WASM_TARGET"]}`, available #{SUPPORTED_WASM_TARGETS.join(", ")}"
    end
  else
    :wasi
  end

OUT_DIR =
  if ENV["OUT_DIR"]
    if File.directory?(ENV["OUT_DIR"])
      Pathname.new(ENV["OUT_DIR"])
    else
      fail "`#{ENV["OUT_DIR"]}` not found or not a directory"
    end
  else
    PROJECT_ROOT.join("bin")
  end

FileUtils.mkdir_p(OUT_DIR)
OUT_WASM = OUT_DIR.join("mruby_engine.wasm").to_s

HOST_MRUBY_BIN_DIR = MRUBY_DIR.join("build/host/bin")
HOST_MRBC_EXE = HOST_MRUBY_BIN_DIR.join("mrbc")

MRUBY_LIB_DIR = MRUBY_DIR.join("build/wasm32-#{WASM_TARGET}/lib")
MRUBY_LIB = MRUBY_LIB_DIR.join("libmruby.a")

namespace(:mruby) do
  def within_mruby
    Dir.chdir(MRUBY_DIR) do
      original_mruby_config = ENV["MRUBY_CONFIG"]
      begin
        ENV["MRUBY_CONFIG"] = "../build_config/wasm32-#{WASM_TARGET}.rb"
        yield
      ensure
        ENV["MRUBY_CONFIG"] = original_mruby_config
      end
    end
  end

  # Workaround because it may compiling fail when changing gembox
  # task(compile: :clean) do
  task(:compile) do
    within_mruby do
      sh("ruby", "./minirake")
    end
  end

  task(:clean) do
    within_mruby do
      FileUtils.rm "../build_config/*.rb.lock"
      sh("ruby", "./minirake", "clean")
    end
  end

  task(:mrproper) do
    within_mruby do
      sh("ruby", "./minirake", "deep_clean")
    end
  end
end

task(clean: %i[mruby:mrproper])

task(mrproper: %i[clean mruby:mrproper])

task(default: %i[mruby:compile])
