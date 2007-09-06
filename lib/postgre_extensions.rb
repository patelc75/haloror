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
      :float       => { :name => "float" },
      :decimal     => { :name => "decimal" },
      :datetime    => { :name => "timestamp" },
      :timestamp   => { :name => "timestamp" },
      :timestamp_with_time_zone => { :name => "timestamp with time zone" },
      :time        => { :name => "time" },
      :date        => { :name => "date" },
      :binary      => { :name => "bytea" },
      :boolean     => { :name => "boolean" }
    }
  end
end
