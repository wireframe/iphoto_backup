require 'thor'
require 'nokogiri'
require 'fileutils'

module IphotoBackup
  class CLI < Thor
    IPHOTO_ALBUM_PATH = "~/Pictures/iPhoto Library.photolibrary/AlbumData.xml"
    DEFAULT_OUTPUT_DIRECTORY = "~/Google Drive/Dropbox"
    IPHOTO_EPOCH = Time.new(2001, 1, 1)

    desc "export [OPTIONS]", "exports iPhoto albums into target directory"
    option :filter, desc: 'filter to only include albums that match the given regex', aliases: '-e', default: '.*'
    option :output, desc: 'directory to export albums to', aliases: '-o', default: DEFAULT_OUTPUT_DIRECTORY
    option :config, desc: 'iPhoto AlbumData.xml file to process', aliases: '-c', default: IPHOTO_ALBUM_PATH
    option :'include-date-prefix', desc: 'automatically include ISO8601 date prefix to exported events', aliases: '-d', default: false, type: :boolean
    option :albums, desc: 'use albums for the export instead of events', aliases: '-a', default: false, type: :boolean
    def export
      each_photoset do |folder_name, album_info|
        say "\n\nProcessing photos: #{folder_name}..."

        each_image(album_info) do |image_info|
          export_image(folder_name, image_info)
        end
      end
    end
    default_command :export

    private

    def export_image(folder_name, image_info)
      source_path = value_for_dictionary_key('ImagePath', image_info).content

      target_path = File.join(File.expand_path(options[:output]), folder_name, File.basename(source_path))
      target_dir = File.dirname target_path
      FileUtils.mkdir_p(target_dir) unless Dir.exists?(target_dir)

      if FileUtils.uptodate?(source_path, [target_path])
        say "  copying #{source_path} to #{target_path}"
        FileUtils.copy source_path, target_path, preserve: true
      else
        print '.'
      end
    end

    def each_photoset(&block)
      if options[:albums]
        each_album(&block)
      else
        each_event(&block)
      end
    end

    def each_event(&block)
      events = value_for_dictionary_key('List of Rolls').children.select {|n| n.name == 'dict' }
      events.each do |album_info|
        event_name = value_for_dictionary_key('RollName', album_info).content
        process_folder(event_name, album_info, &block)
      end
    end

    def each_album(&block)
      albums = value_for_dictionary_key('List of Albums').children.select {|n| n.name == 'dict' }
      albums.each do |album_info|
        album_name = value_for_dictionary_key('AlbumName', album_info).content
        next if album_name == 'Photos'
        process_folder(album_name, album_info, &block)
      end
    end

    def process_folder(folder, album_info, &block)
      folder_name = add_date_to_folder_name(folder, album_info)

      if folder_name.match(album_filter)
        yield folder_name, album_info
      else
        say "\n\n#{folder_name} does not match the filter: #{album_filter.inspect}"
      end
    end

    def add_date_to_folder_name(folder_name, album_info)
      return folder_name unless options[:'include-date-prefix']
      return folder_name if folder_name =~ /^\d{4}-\d{2}-\d{2} /
      [album_date(album_info), folder_name].compact.join(' ')
    end

    # infer the date from the first image within the album
    def album_date(album_info)
      album_date = nil
      each_image album_info do |image_info|
        next if album_date
        photo_interval = value_for_dictionary_key('DateAsTimerInterval', image_info).content.to_i
        album_date = (IPHOTO_EPOCH + photo_interval).strftime('%Y-%m-%d')
      end
      album_date
    end

    def each_image(album_info, &block)
      album_images = value_for_dictionary_key('KeyList', album_info).css('string').map(&:content)
      album_images.each do |image_id|
        image_info = info_for_image image_id
        yield image_info
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

    def album_filter
      @album_filter ||= Regexp.new(options[:filter])
    end

    def master_images
      @master_images ||= value_for_dictionary_key "Master Image List"
    end

    def root_dictionary
      @root_dictionary ||= begin
        file = File.expand_path options[:config]
        say "Loading AlbumData: #{file}"
        doc = Nokogiri.XML(File.read(file))
        doc.child.children.find {|n| n.name == 'dict' }
      end
    end
  end
end
