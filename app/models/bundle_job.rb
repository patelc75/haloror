class BundleJob
  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
  ARCHIVE_PATH = "#{RAILS_ROOT}/archive"
  EXT_NAME = '.tar.bz2'
  def self.job_process_bundles
    RAILS_DEFAULT_LOGGER.warn("BundleJob.job_process_bundle running at #{Time.now}")
   
    begin 
      Dir.mkdir(BUNDLE_PATH) unless File.exists?(BUNDLE_PATH)
      Dir.mkdir(ARCHIVE_PATH) unless File.exists?(ARCHIVE_PATH)
      #retrieve file names
      file_names = []
      Dir.foreach(BUNDLE_PATH) do |file_name|
        unless file_name == '.' || file_name == '..' || file_name.include?('.part')
          file_names << file_name
        end
      end
      if file_names.size == 0
        return nil
      end
      while file_names.size > 0
        file_names = process_files(file_names)
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn "BUNDLE_JOB_EXCEPTION:  #{e}"
    end
  end
  
  def self.process_files(file_names)
    
    #select oldest file
    file_name = select_oldest_file_for_processing(file_names)
    file_names.delete_if do |name|
      name == file_name
    end
    file_path_and_name = "#{BUNDLE_PATH}/#{file_name}"
    #create dir with file_name - extension
    base_name = File.basename(file_path_and_name, EXT_NAME)
    dir_path = "#{BUNDLE_PATH}/#{base_name}"
    begin
      Dir.mkdir(dir_path)
    rescue
      #dir already exists so file already being processed, returning file_names early
      return file_names
    end
    #extract file into dir
    self.extract(file_path_and_name,  dir_path)
    self.archive(file_path_and_name,  ARCHIVE_PATH)
    #retrieve file names
    xml_file_names = []
    Dir.foreach(dir_path) do |xml_file_name|
      unless xml_file_name == '.' || xml_file_name == '..'
        xml_file_names << xml_file_name
      end
    end
    while xml_file_names.size > 0
      #select oldest file, but first in sequence
      xml_file_name = select_oldest_xml_file_for_processing(xml_file_names)
      xml_file_path_and_name = "#{dir_path}/#{xml_file_name}"
      #read file into string
      xml_string = File.read(xml_file_path_and_name)
      puts xml_string
      #convert to hash
      bundle_hash = Hash.from_xml(xml_string)
      #call bundle processor on hash (aka bundle)
      BundleProcessor.process(bundle_hash['bundle'])
      #delete xml file
      File.delete(xml_file_path_and_name)
      xml_file_names.delete_if do |name|
        xml_file_name = name
      end
    end
    
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
        return afile
      else
        return bfile
      end
    end
    return file_names[0]
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
          return afile
        else
          return bfile
        end
      elsif atime < btime
        return afile
      else
        return bfile
      end
    end
    return xml_file_names[0]
  end
  def self.get_time_in_seconds_xml(file_name)
    base_name = File.basename(file_name, '.xml')
    puts "base_name:  #{base_name}"
    i = base_name.index('_')
    str = base_name[i + 1, base_name.size - i - 1]
    puts "str:  #{str}"
    i = str.index('_')
    sequence_num = str[i + 1, str.size - i - 1]
    puts "sequence_num:  #{sequence_num}"
    seconds_string = base_name[11, base_name.size - 11 - sequence_num.size - 1]
    puts seconds_string
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