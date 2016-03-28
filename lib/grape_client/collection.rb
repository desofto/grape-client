module GrapeClient
  class Collection
    attr_reader :count

    def initialize(clazz, elements, headers = nil)
      @is_first_page = true
      @clazz = clazz
      update(elements, headers)
    end

    def first
      @clazz.new(@elements.first) if @elements.any?
    end

    def each(&_block)
      per_page do |elements|
        elements.each do |attrs|
          yield @clazz.new(attrs)
        end
      end
    end

    def map(&_block)
      result = []
      per_page do |elements|
        result += elements.map do |attrs|
          yield @clazz.new(attrs)
        end
      end
      result
    end

    def collect
      result = []
      per_page do |elements|
        result += elements
      end
      result
    end

    def empty?
      @is_first_page && @elements.empty?
    end

    def any?
      !empty?
    end

    private

    def per_page
      prepare_for_iteration
      loop do
        yield @elements
        break unless load_next_page
      end
    end

    def update(elements, headers = nil)
      @elements = elements
      @count = headers['total'.freeze].first.try(:to_i) if headers
      @count ||= @elements.length
      @first_page_link = extract_first_page_link(headers)
      @next_page_link = extract_next_page_link(headers)
    end

    def prepare_for_iteration
      return if @is_first_page
      load_first_page
    end

    def load_next_page
      return unless load_page @next_page_link
      @is_first_page = false
      true
    end

    def load_first_page
      return unless load_page @first_page_link
      @is_first_page = true
      true
    end

    def load_page(link)
      return unless link.present?
      response = @clazz.connection.request :get, link
      update ResponseParser.new(response, @clazz).collection, @clazz.connection.headers
      true
    end

    def extract_first_page_link(headers)
      extract_page_link(headers, :first)
    end

    def extract_next_page_link(headers)
      extract_page_link(headers, :next)
    end

    def extract_page_link(headers, title)
      return unless headers.present?
      links = headers['link'.freeze].try(:first)
      return unless links.present?
      links = links.split(','.freeze).map do |link|
        link = link.split(';'.freeze).map(&:strip)
        link.delete("rel=\"#{title}\"".freeze) ? link : nil
      end.compact.flatten
      return unless links.any?
      links.first[1..-2]
    end
  end
end
