# rails query logs

puts "Usage: #{$0} file" unless ARGV.size == 1

file = ARGV[0]
puts "Checking: #{file}"

class Entry
  include Enumerable

  attr_accessor :name
  attr_accessor :time
  attr_accessor :query

  def initialize(name, time, query)
    @name, @time, @query = name, time.to_f, query
  end

  def to_s
    "%s (%s) %s" % [name, time, query]
  end

  def <=>(other)
    time <=> other.time
  end

end

class EntrySum
  include Enumerable

  attr_accessor :name
  attr_accessor :total_time
  attr_accessor :total_calls


  def initialize(name)
    @name = name
    @total_time  = 0
    @total_calls = 0
  end

  def add_time(time)
    @total_time = @total_time + time
  end

  def add_call
    @total_calls = @total_calls + 1
  end

  def <=>(other)
    @total_time <=> other.total_time
  end
end

class LogParser
  attr_accessor :log

  def initialize(log)
    @log = log
  end

  def entries
    e = []
    @log.gsub(entries_regex) do |text|
      name = $1
      associations = $2
      time = $3
      query = $4 + $5
      e << Entry.new(name, time, query)
    end
    e
  end

  private
  def entries_regex
    /\s+(.*?)Load(.*)\((\d+\.\d+)\)\s+(SELECT)(.*?)\n/
  end

end

contents = File.read(file)

lp = LogParser.new(contents)

lp.entries.sort.each do |e|
  puts "%20s %0.8f %s" % [e.name, e.time, e.query]
end

puts 
puts "=========== Totals ===========" 
puts 

totals = {}

lp.entries.each do |e|
  totals[e.name] = EntrySum.new(e.name) unless totals.has_key?(e.name)
  totals[e.name].add_call
  totals[e.name].add_time(e.time) 
end

totals.values.sort.each do |v|
  puts "%25s %0.8f (%3d calls, avg. %0.8f)" % [v.name, v.total_time, v.total_calls, v.total_time / v.total_calls]
end
