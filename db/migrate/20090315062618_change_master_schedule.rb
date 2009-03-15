class ChangeMasterSchedule < ActiveRecord::Migration
  def self.up
    Schedule.transaction do
      add_schedules(:id => 1, :level => 1, :span => 1)
      add_schedules(:id => 2, :level => 2, :span => 7)
      add_schedules(:id => 3, :level => 3, :span => 30)
      add_schedules(:id => 4, :level => 4, :span => 182)
    end
  end

  def self.down
    Schedule.transaction do
      Schedule.destroy(Schedule.find_by_level(1))
      Schedule.destroy(Schedule.find_by_level(2))
      Schedule.destroy(Schedule.find_by_level(3))
      Schedule.destroy(Schedule.find_by_level(4))
    end
  end

  private
  def self.add_schedules(params={})
    unless Schedule.find_by_level(params[:level])
      s = Schedule.new(params)
      s.id = params[:id]
      s.save!
    end
  end
end
