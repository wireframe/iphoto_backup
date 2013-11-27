require 'thor'
require 'nokogiri'
require 'fileutils'

module IphotoBackup
  class CLI < Thor
    IPHOTO_ALBUM = "~/Pictures/iPhoto Library.photolibrary/AlbumData.xml"
    OUTPUT_DIRECTORY = "~/tmp/Google Drive/Dropbox"

    desc "export iPhoto albums", "exports iPhoto albums into target directory"
    # option :regex, aliases: '-e'
    def export
      albums = value_for_dictionary_key("List of Rolls").children.select {|n| n.name == 'dict' }
      master_images = value_for_dictionary_key "Master Image List"

      albums.each do |album|
        folder = value_for_dictionary_key('RollName', album).content
        # TODO: check if folder matches regex

        say "\n\nProcessing Roll: #{folder}..."

        album_images = value_for_dictionary_key('KeyList', album).css('string').map(&:content)
        album_images.each do |image_id|
          image_info = value_for_dictionary_key image_id, master_images

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

    def root_dictionary
      @root_dictionary ||= begin
        file = File.expand_path IPHOTO_ALBUM
        doc = Nokogiri.XML(File.read(file))
        doc.child.children.find {|n| n.name == 'dict' }
      end
    end
  end
end
