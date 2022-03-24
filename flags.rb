# frozen_string_literal: true

WASI_SDK_ROOT = ENV['WASI_SDK_PATH'] || fail('Specify WASI_SDK_PATH environment variable!')

module Flags
  class << self
    def optimization_flags
      if ENV["MRUBY_ENGINE_ENABLE_DEBUG"]
        %w[-O0]
      else
        %w[-O3 -Os]
      end
    end

    def cflags
      optimization_flags
    end

    def wasm32_cflags
      optimization_flags
    end

    def linker_flags
      %w[]
    end

    def wasm32_linker_flags
      %w[-m32 -flto]
    end

    def library_paths
      # Necessary because of https://github.com/mruby/mruby/issues/4537
      %w[/usr/local/lib /usr/lib]
    end

    def io_safe_defines
      %w[
        MRB_UTF8_STRING
        MRB_WORD_BOXING
      ]
    end

    def defines
      io_safe_defines + %w[
        MRB_WORDBOX_NO_FLOAT_TRUNCATE
        MRB_USE_RO_DATA_P_ETEXT
      ]
    end

    def wasm32_defines
      io_safe_defines + %w[
        MRB_GC_TURN_OFF_GENERATIONAL
        MRB_WORDBOX_NO_FLOAT_TRUNCATE
        MRB_USE_RO_DATA_P_ETEXT
        MRB_NO_STDIO
      ]
    end
  end
end
