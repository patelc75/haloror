class Step < Vital
  set_table_name "steps"
  def self.node_name
    return :step
  end
  def self.get_average(condition)
    Step.average(:heartrate, :conditions => condition)
  end
end
