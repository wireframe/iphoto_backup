require 'thor'
require 'nokogiri'
require 'fileutils'

module IphotoBackup
  class CLI < Thor
    IPHOTO_ALBUM_PATH = "~/Pictures/iPhoto Library.photolibrary/AlbumData.xml"
    OUTPUT_DIRECTORY = "~/tmp/Google Drive/Dropbox"

    desc "export iPhoto albums", "exports iPhoto albums into target directory"
    option :filter, aliases: '-e', default: '.*'
    def export
      filter = Regexp.new options[:filter]

      each_album do |album|
        folder = value_for_dictionary_key('RollName', album).content

        unless folder.match(filter)
          say "\n\n#{folder} does not match the filter: #{filter.inspect}"
          next
        end

        say "\n\nProcessing Roll: #{folder}..."

        album_images = value_for_dictionary_key('KeyList', album).css('string').map(&:content)
        album_images.each do |image_id|
          image_info = info_for_image image_id
          source_path = value_for_dictionary_key('ImagePath', image_info).content

          target_path = File.join(File.expand_path(OUTPUT_DIRECTORY), folder, File.basename(source_path))
          target_dir = File.dirname target_path
          FileUtils.mkdir_p(target_dir) unless Dir.exists?(target_dir)

          if FileUtils.uptodate?(source_path, [ target_path ])
            say "  copying #{source_path} to #{target_path}"
            FileUtils.copy source_path, target_path, preserve: true
          else
            print '.'
          end
        end
      end
    end

    private

    def each_album(&block)
      albums = value_for_dictionary_key("List of Rolls").children.select {|n| n.name == 'dict' }
      albums.each do |album|
        yield album
      end
    end

    def info_for_image(image_id)
      value_for_dictionary_key image_id, master_images
    end

    def value_for_dictionary_key(key, dictionary = root_dictionary)
      key_node = dictionary.children.find {|n| n.name == 'key' && n.content == key }
      next_element key_node
    end

    # find next available sibling element
    def next_element(node)
      element_node = node
      while element_node != nil  do
        element_node = element_node.next_sibling
        break if element_node.element?
      end
      element_node
    end

    def master_images
      @master_images ||= value_for_dictionary_key "Master Image List"
    end

    def root_dictionary
      @root_dictionary ||= begin
        file = File.expand_path IPHOTO_ALBUM_PATH
        doc = Nokogiri.XML(File.read(file))
        doc.child.children.find {|n| n.name == 'dict' }
      end
    end
  end
end
