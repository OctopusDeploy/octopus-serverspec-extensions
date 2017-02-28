require 'serverspec'
require 'serverspec/type/base'
require 'csv'

module Serverspec::Type
  class WindowsScheduledTask < Base
    attr_reader :state, :user_id, :run_level, :schedule_type, :repeat_every
    @exists = false

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner

      stdout = `schtasks /query /tn \"#{name}\" /fo csv /v`
      return unless $?.success?
      csv = CSV.parse(stdout)
      @exists = true
      headers = csv[0]
      data = csv[1]
      @state = data[headers.index{|x|x=="Status"}]
      @user_id = data[headers.index{|x|x=="Run As User"}]
      @run_level = data[headers.index{|x|x=="Logon Mode"}]
      @schedule_type = data[headers.index{|x|x=="Schedule Type"}].strip
      @repeat_every = data[headers.index{|x|x=="Repeat: Every"}]
    end
  end

  def windows_scheduled_task(name)
    WindowsScheduledTask.new(name)
  end
end

include Serverspec::Type
