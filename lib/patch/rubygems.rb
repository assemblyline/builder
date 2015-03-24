module Gem
  class Package
    class TarWriter
      def add_file_simple(name, mode, size) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        check_closed

        name, prefix = split_name name

        header = Gem::Package::TarHeader.new(name: name, mode: mode,
                                             size: size, prefix: prefix,
                                             mtime: Time.at(1)).to_s

        @io.write header
        os = BoundedStream.new @io, size

        yield os if block_given?

        min_padding = size - os.written
        @io.write("\0" * min_padding)

        remainder = (512 - (size % 512)) % 512
        @io.write("\0" * remainder)

        self
      end
    end
  end
end
