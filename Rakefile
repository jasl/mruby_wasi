# frozen_string_literal: true

require "pathname"
require "fileutils"
require_relative "./flags"

MRUBY_DIR = Pathname.new(__dir__).join("mruby")
raise(<<-MESSAGE) unless Dir.exist?(MRUBY_DIR.join("src"))

  The mruby source code appears to be missing. Did you clone this gem with
  submodules? If that is not the case or you are unsure, you can run the
  following commands:

    $ git submodule init
    $ git submodule update

MESSAGE

PROJECT_ROOT = Pathname.new(__dir__)
ROOT =
  if ENV["TARGET_DIR"] && File.directory?(ENV["TARGET_DIR"])
    Pathname.new(ENV["TARGET_DIR"])
  elsif ENV["INSTALL_DIR"] && File.directory?(ENV["INSTALL_DIR"])
    Pathname.new(ENV["INSTALL_DIR"])
  else
    PROJECT_ROOT
  end

OUT_DIR = ROOT.join("bin")
FileUtils.mkdir_p(OUT_DIR)
OUT_WASM = OUT_DIR.join("mruby_engine.wasm").to_s

MRUBY_BIN_DIR = MRUBY_DIR.join("build/host/bin")
MRBC_EXE = MRUBY_BIN_DIR.join("mrbc")

MRUBY_LIB_DIR = MRUBY_DIR.join("build/wasm32-unknown-wasi/lib")
MRUBY_LIB = MRUBY_LIB_DIR.join("libmruby.a")

namespace(:mruby) do
  def within_mruby
    Dir.chdir(MRUBY_DIR) do
      original_mruby_config = ENV["MRUBY_CONFIG"]
      begin
        ENV["MRUBY_CONFIG"] = "../mruby_config.rb"
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
      sh("rm", "../mruby_config.rb.lock") if File.exist?("../mruby_config.rb.lock")
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
