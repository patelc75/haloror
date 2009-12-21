module ActiveRecord::ConnectionAdapters::SchemaStatements

  def add_index_with_quiet(table_name, column_names, options = {})
    quiet = options.delete(:quiet)
    add_index_without_quiet table_name, column_names, options
  rescue
    raise unless quiet and $!.message =~ /^Mysql::Error: Duplicate key name/i
    puts "Failed to create index #{table_name} #{column_names.inspect} #{options.inspect}"
  end
  alias_method_chain :add_index, :quiet

  def remove_index_with_quiet(table_name, *args)
    options = args.extract_options!
    quiet = options.delete(:quiet)
    remove_index_without_quiet table_name, *args
  rescue
    raise unless quiet and $!.message =~ /^Mysql::Error: Can't DROP/i
    puts "Failed to drop index #{table_name} #{(args[1]||options[:name]).inspect}"
  end
  alias_method_chain :remove_index, :quiet
end
