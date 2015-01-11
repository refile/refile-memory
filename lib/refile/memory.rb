require "refile"
require "refile/memory/version"

module Refile
  module Memory
    class Backend
      attr_reader :directory

      attr_reader :max_size

      def initialize(max_size: nil, hasher: Refile::RandomHasher.new)
        @hasher = hasher
        @max_size = max_size
        @store = {}
      end

      def upload(uploadable)
        Refile.verify_uploadable(uploadable, @max_size)

        id = @hasher.hash(uploadable)

        @store[id] = uploadable.read

        Refile::File.new(self, id)
      end

      def get(id)
        Refile::File.new(self, id)
      end

      def delete(id)
        @store.delete(id)
      end

      def open(id)
        StringIO.new(@store[id])
      end

      def read(id)
        @store[id]
      end

      def size(id)
        @store[id].bytesize if exists?(id)
      end

      def exists?(id)
        @store.has_key?(id)
      end

      def clear!(confirm = nil)
        raise Refile::Confirm unless confirm == :confirm
        @store = {}
      end
    end
  end
end
