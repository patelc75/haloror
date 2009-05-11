class BundleJob
  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
  ARCHIVE_PATH = "#{RAILS_ROOT}/dialup/archive"
  EXT_NAME = '.tar.bz2'
  def self.job_process_bundles
    RAILS_DEFAULT_LOGGER.warn("BundleJob.job_process_bundle running at #{Time.now}")
   
    begin 
      Dir.mkdir(BUNDLE_PATH) unless File.exists?(BUNDLE_PATH)
      Dir.mkdir(ARCHIVE_PATH) unless File.exists?(ARCHIVE_PATH)
      #retrieve file names
      file_names = []
      Dir.foreach(BUNDLE_PATH) do |file_name|  #create list of filenames that need to be processed
        unless file_name == '.' || file_name == '..' || file_name.include?('.part')
          file_names << file_name
        end
      end
      if file_names.size == 0  #if not files, return nil
        return nil
      end
      while file_names.size > 0 
        file_names = process_files(file_names) #after file is process, the name is removed from the array
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn "BUNDLE_JOB_EXCEPTION:  #{e}"
    end
  end
  
  def self.process_files(file_names) #array of filenames passed in
    
    #select oldest file
    file_name = select_oldest_file_for_processing(file_names)
    file_names.delete_if do |name| #delete the filename 
      name == file_name
    end
    file_path_and_name = "#{BUNDLE_PATH}/#{file_name}"  #append filename to path to create a new dir
    #create dir with file_name - extension
    base_name = File.basename(file_path_and_name, EXT_NAME) #remove extension from filename
    dir_path = "#{BUNDLE_PATH}/#{base_name}"
    begin
      Dir.mkdir(dir_path) #try to make the directory
    rescue
      #dir already exists so file already being processed, returning file_names early
      return file_names
    end
    #extract file into dir
    self.extract(file_path_and_name,  dir_path) 
    self.archive(file_path_and_name,  ARCHIVE_PATH) #archive the file to the /archive directory
    #retrieve file names
    xml_file_names = []  
    Dir.foreach(dir_path) do |xml_file_name|  #crate an array of the xml file names
      unless xml_file_name == '.' || xml_file_name == '..'
        xml_file_names << xml_file_name
      end
    end
    while xml_file_names.size > 0
      #select oldest file, but first in sequence
      xml_file_name = select_oldest_xml_file_for_processing(xml_file_names) #xml files have a timestamp
      xml_file_path_and_name = "#{dir_path}/#{xml_file_name}"
      #read file into string
      xml_string = File.read(xml_file_path_and_name)
      #convert to hash
      bundle_hash = Hash.from_xml(xml_string)
      #call bundle processor on hash (aka bundle)
      BundleProcessor.process(bundle_hash['bundle']) #processes bundle hash, can't use a symbol, have to pass in 'bundle'
      #delete xml file
      File.delete(xml_file_path_and_name)
      xml_file_names.delete_if do |name|
        xml_file_name == name
      end
    end
    
    Dir.delete(dir_path)
    delete_oldest_file_from_archive
    return file_names
  end
  
  def self.select_oldest_file_for_processing(file_names)
    if file_names.size == 1
      return file_names[0]
    end
    file_names.sort! do |afile, bfile|
      atime = get_time_in_seconds(afile)
      btime = get_time_in_seconds(bfile)
      if atime <= btime
        -1
      else
        1
      end
    end
    return file_names[0]
  end
  
  def self.delete_oldest_file_from_archive
  	archive_file_names = []
      Dir.foreach(ARCHIVE_PATH) do |file_name|  #create list of zip files from archive directory
        unless file_name == '.' || file_name == '..' 
          archive_file_names << file_name
        end
      end

      if archive_file_names.size == 0  #if not files, return nil
        return nil
	  elsif archive_file_names.size > DIAL_UP_ARCHIVE_FILES_TO_KEEP   #if more archive files then get oldest first in array for remove
  	  	archive_file_names.sort! do |afile, bfile|
      		atime = get_time_in_seconds(afile)
      		btime = get_time_in_seconds(bfile)
      		if atime <= btime
      	  	 -1
      		else
      		  1
      		end
    	end
    	archive_file_path = ARCHIVE_PATH + '/' + archive_file_names[0]
    	File.delete(archive_file_path)
      else
  	    	return nil
      end
  end
  
  def self.get_time_in_seconds(file_name)
    base_name = File.basename(file_name, EXT_NAME)
    seconds_string = base_name[11, base_name.size - 11]
    return seconds_string.to_i
  end
  
  def self.select_oldest_xml_file_for_processing(xml_file_names)
    if xml_file_names.size == 1
      return xml_file_names[0]
    end
    xml_file_names.sort! do |afile, bfile|
      atime, aseq = get_time_in_seconds_xml(afile)
      btime, bseq = get_time_in_seconds_xml(bfile)
      if atime == btime
        if aseq <= bseq
            -1
        else
          1
        end
      elsif atime < btime
        -1
      else
        1
      end
    end
    return xml_file_names[0]
  end
  def self.get_time_in_seconds_xml(file_name)
    base_name = File.basename(file_name, '.xml')
    i = base_name.index('_')
    str = base_name[i + 1, base_name.size - i - 1]
    i = str.index('_')
    sequence_num = str[i + 1, str.size - i - 1]
    seconds_string = base_name[11, base_name.size - 11 - sequence_num.size - 1]
    return seconds_string.to_i, sequence_num.to_i
  end
  def self.archive(file_path_and_name, directory)
    command = "mv #{file_path_and_name} #{directory}"
    success = system(command)
    success && $?.exitstatus == 0
  end
  def self.extract(file_path_and_name, directory)
    command = "tar -xjf #{file_path_and_name} -C #{directory}"
    success = system(command)
    success && $?.exitstatus == 0
  end
end