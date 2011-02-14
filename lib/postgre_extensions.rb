# postgre_extensions.rb
# August 15, 2007
#
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def native_database_types
    {
      :primary_key => "serial primary key",
      :string      => { :name => "character varying", :limit => 255 },
      :text        => { :name => "text" },
      :integer     => { :name => "integer" },
      :float       => { :name => "float" },    #uses 'numeric' type in Pg (variable length)
      :decimal     => { :name => "decimal" },  #uses 'double precision type in Pg (8 bytes)
      :datetime    => { :name => "timestamp" },
      :timestamp   => { :name => "timestamp" },
      :timestamp_with_time_zone => { :name => "timestamp with time zone" },
      :time        => { :name => "time" },
      :date        => { :name => "date" },
      :binary      => { :name => "bytea" },
      :boolean     => { :name => "boolean" },
      :real        => { :name => "real" },     #uses 'real'type in Pg (4 bytes)  
      :interval    => { :name => "interval" }     
    }
  end
end
