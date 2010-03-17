class BundleJob
  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
  ARCHIVE_PATH = "#{RAILS_ROOT}/dialup/archive"
  EXT_NAME = '.tar.bz2'
  @error_collection = []
  
  class << self
    
    def job_process_bundles
      RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob.job_process_bundle running")
      @error_collection = []
   
      begin 
        ensure_folder(BUNDLE_PATH)
        ensure_folder(ARCHIVE_PATH)
        #retrieve file names
        file_names = []
        Dir.foreach(BUNDLE_PATH) do |file_name|  #create list of filenames that need to be processed
          unless file_name == '.' || file_name == '..' || 
                 file_name.include?('.part') || file_name == "archive" ||
                 (!file_name.include?(EXT_NAME) && 
                    !File.directory?("#{BUNDLE_PATH}/#{file_name}"))
               
            file_names << file_name
          end
        end
        if file_names.size == 0  #if not files, return nil
          return nil
        end
      
        # sort the filenames once
        file_names.sort! do |afile, bfile|
          get_time_in_seconds(afile) <=> get_time_in_seconds(bfile)
        end

        self.process_files(file_names)

      rescue Exception => e
        @error_collection << "#{Time.now}: BUNDLE_JOB_EXCEPTION while finding files:  #{e}"
        RAILS_DEFAULT_LOGGER.warn "#{Time.now}: BUNDLE_JOB_EXCEPTION while finding files:  #{e}"
      end
    
      if !@error_collection.blank?
        RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob.job_process_bundle finished with errors")
        error_string = "BUNDLE JOB PROCESSING: the following errors were logged:\n %s" % [@error_collection.join("\n")]
        @error_collection = []
        raise error_string
      end
      RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob.job_process_bundle finished")
    end
  
    def process_files(file_names)
      RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob.job_process_files started")
    
      begin
        file_names.each do |file_name|
          file_path_and_name = "#{BUNDLE_PATH}/#{file_name}"
          
          if (file_name.include?(EXT_NAME) && !File.directory?(file_path_and_name))

            base_name = File.basename(file_path_and_name, EXT_NAME) #remove extension from filename
            dir_path = "#{BUNDLE_PATH}/#{base_name}"
            Dir.mkdir(dir_path) rescue nil #try to make the directory
            self.extract(file_path_and_name,  dir_path) 
            self.archive(file_path_and_name,  ARCHIVE_PATH) #archive the file to the /archive directory
            RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob beginng work on extracted #{file_name}")
          
          else
            RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob beginng work on directory #{file_name}")
            dir_path = file_path_and_name
          end
        
          if File.directory?(dir_path)
            begin
              self.process_xml_files_in_dir(dir_path)
              # CHANGED: Dir.delete(dir_path)
              # recursively delete the folders. We can expect subfolders
              recursively_delete_dir(dir_path)
              delete_oldest_file_from_archive
            rescue Exception => e
              @error_collection << "#{Time.now}: BUNDLE_JOB_EXCEPTION while processing a directory:  #{e}"
              RAILS_DEFAULT_LOGGER.warn "#{Time.now}: BUNDLE_JOB_EXCEPTION while processing a directory:  #{e}"
            end
          elsif file_name.include?(".xml")
            # @error_collection << "Found a random xml file in the bundle dir:  #{file_name}"
            RAILS_DEFAULT_LOGGER.warn "#{Time.now}: Found a random xml file in the bundle dir:  #{file_name}"
            # process a single XML file here, sometime
          end
        
        end
      rescue Exception => e
        @error_collection << "#{Time.now}: BUNDLE_JOB_EXCEPTION in process_files:  #{e}"
        RAILS_DEFAULT_LOGGER.warn "#{Time.now}: BUNDLE_JOB_EXCEPTION in process_files:  #{e}"
      end
    
      RAILS_DEFAULT_LOGGER.warn("#{Time.now}: BundleJob.job_process_files finished")
    
    end
    
    def process_xml_files_in_dir(dir_path)
      # CHANGED: get all *.xml files in any subfolder within this folder
      # this fetch works recursively
      xml_file_names = Dir.glob( File.join(dir_path, "**", "*.xml"))
      # Dir.foreach(dir_path) do |xml_file_name|  #crate an array of the xml file names
      #   unless xml_file_name == '.' || xml_file_name == '..'
      #     xml_file_names << xml_file_name
      #   end
      # end
      # FIXME: Why are we sorting here? Do we really need the sorted order of files?
      # We are going to process all of them anyways. Isn't it?
      # xml_file_names.sort! do |afile, bfile|
      #   atime, aseq = get_time_in_seconds_xml(afile)
      #   btime, bseq = get_time_in_seconds_xml(bfile)
      #   (atime == btime) ? (aseq <=> bseq) : (atime <=> btime)
      #   # if atime == btime
      #   #   aseq <=> bseq
      #   # else
      #   #   atime <=> btime
      #   # end
      # end

      xml_file_names.each do |xml_file_name|
        begin
          # we now have full path to file from Dir.glob above
          # xml_file_path_and_name = "#{dir_path}/#{xml_file_name}"
          self.process_xml_file(xml_file_name)
          #delete xml file
          File.delete(xml_file_name)
        rescue Exception => e
          error_message = "#{Time.now}: BUNDLE_JOB_EXCEPTION in process_xml_files_in_dir for #{xml_file_name}: #{e}"
          @error_collection << error_message
          RAILS_DEFAULT_LOGGER.warn error_message
        end
      end
    end
    
    def process_xml_file(xml_file_path_and_name)
      unless (xml_string = File.read(xml_file_path_and_name)).blank?
        unless (bundle_hash = Hash.from_xml(xml_string)).blank?
          self.process_xml_data(bundle_hash)
        end
      end
    end

    # process the XML data. no file handling here.
    #
    def process_xml_data(bundle_hash)
      bundle_hash.keys.each do |key|
        BundleProcessor.process(bundle_hash[key]) unless bundle_hash[key].blank?
      end unless bundle_hash.blank?
    end
  
    def select_oldest_file_for_processing(file_names)
      # if file_names.size == 1
      #   return file_names[0]
      # end
      file_names.sort! {|afile, bfile| (get_time_in_seconds(afile) <= get_time_in_seconds(bfile)) ? -1 : 1 } \
        unless file_names.blank? || file_names.size <= 1 # no element? do not sort. just in case
      # file_names.sort! do |afile, bfile|
      #   atime = get_time_in_seconds(afile)
      #   btime = get_time_in_seconds(bfile)
      #   if atime <= btime
      #     -1
      #   else
      #     1
      #   end
      # end
      return file_names[0]
    end
  
    def delete_oldest_file_from_archive
      archive_file_names = []
      Dir.foreach(ARCHIVE_PATH) do |file_name|  #create list of zip files from archive directory
        unless file_name == '.' || file_name == '..' || 
              File.directory?("#{ARCHIVE_PATH}/#{file_name}")
          archive_file_names << file_name
        end
      end

      # FIXME: Need to cover this with BDD/TDD
      #   what is returned when we do have data? why the 'return nil' then?
      if archive_file_names.size == 0  #if not files, return nil
        return nil
      elsif archive_file_names.size > DIAL_UP_ARCHIVE_FILES_TO_KEEP_MIN   #if more archive files then get oldest first in array for remove
        archive_file_names.sort! do |afile, bfile|
          get_time_in_seconds(afile) <=> get_time_in_seconds(bfile)
        end
      
        archive_file_path = ARCHIVE_PATH + '/' + archive_file_names[0]
        if (!File.directory?(archive_file_path))
          File.delete(archive_file_path)
        end
      else
        return nil
      end
    end

    # FIXME: Use RegEx here for better results. Provide example of usage
    def get_time_in_seconds(file_name)
      base_name = File.basename(file_name, EXT_NAME)
      seconds_string = base_name[11, base_name.size - 11]
      return seconds_string.to_i
    end
  
    def select_oldest_xml_file_for_processing(xml_file_names)
      # if xml_file_names.size == 1
      #   return xml_file_names[0]
      # end
      xml_file_names.sort! do |afile, bfile|
        atime, aseq = get_time_in_seconds_xml(afile)
        btime, bseq = get_time_in_seconds_xml(bfile)
        (atime == btime) ? (aseq <=> bseq) : (atime <=> btime)
        # if atime == btime
        #   if aseq <= bseq
        #       -1
        #   else
        #     1
        #   end
        # elsif atime < btime
        #   -1
        # else
        #   1
        # end
      end unless xml_file_names.size <= 1
      return xml_file_names[0]
    end
  
    def get_time_in_seconds_xml(file_name)
      base_name = File.basename(file_name, '.xml')
      i = base_name.index('_')
      str = base_name[i + 1, base_name.size - i - 1]
      i = str.index('_')
      sequence_num = str[i + 1, str.size - i - 1]
      seconds_string = base_name[11, base_name.size - 11 - sequence_num.size - 1]
      return seconds_string.to_i, sequence_num.to_i
    end
  
    def archive(file_path_and_name, directory)
      command = "mv -f #{file_path_and_name} #{directory}"
      success = system(command)
      success && $?.exitstatus == 0
    end
  
    def extract(file_path_and_name, directory)
      command = "tar -xjf #{file_path_and_name} -C #{directory}"
      success = system(command)
      success && $?.exitstatus == 0
    end
    
  end # << self
end  