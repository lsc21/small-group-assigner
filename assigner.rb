require 'csv'
require 'json'

# 1. Set ideal group size (total attendees ÷ 6 )
IDEAL_GROUP_SIZE = 6

# 0. Load data
DATA_FILE_PATH = ENV['DATA_FILE_PATH'] || 'data.csv'

@members = []
@groups = []
@count = 0

def overweight_groups
  @groups.select{|g| g.count > 6}
end

def rebalance_groups index
  random_group = overweight_groups.sample
  member = random_group.sample
  random_group.delete(member)
  group = member[:choices][index] - 1
  @groups[group] << member
end

def assign_groups
  @members.each do |member|
    group = member[:choices][0] - 1
    @groups[group].nil? && @groups[group] = []
    @groups[group] << member
  end
end

def rebalance index
  while overweight_groups.any? and @count < @members.count
    rebalance_groups index
    @count = @count + 1
  end
end


data = CSV.read(DATA_FILE_PATH)
data.shift
data.each do |row|
  @members << {
    name: row[0],
    choices: row.slice(1, 3).map(&:to_i)
  }
end

assign_groups

rebalance 1
@count = 0
rebalance 2

p @groups
