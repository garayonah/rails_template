require 'roo'

class SpreadsheetUpload
  attr_accessor :file
  def initialize(file, options: {})
    #Name that will be used for log filenames
    @savename = options[:savename].presence||Time.now.strftime('%Y%m%d%H%M%S')

    #Directory that log results will be saved in
    @directory = options[:directory].presence||''

    #What to do depending on what class the 'file' parameter is
    if file.kind_of? String #If 'file' is a string, search for a file with that name
      @savename||= File.basename(file, File.extname(file))+Time.now.strftime('%Y%m%d%H%M%S')
      @directory||= File.dirname(file)
      @file = Roo::Spreadsheet.open(file)
    elsif file.kind_of? File #If 'file' is a string, search for a file with that name
      @savename||= File.basename(file.path, File.extname(file.path))+Time.now.strftime('%Y%m%d%H%M%S')
      @directory||= File.dirname(file.path)
      @file = Roo::Spreadsheet.open(file)
    elsif file.kind_of? Roo::Base
      @file = file
    end
  
    # @logfiles = []
    # new_logfiles = options[:logfiles]||[]
    # new_logfiles.each do |logfile|
    #   create_logfile(logfile[:name], logfile[:headers])
    # end
  end

  def loop(options={})
    if (options[:only_rows].kind_of? Array) or (options[:only_rows].kind_of? Range)
      rows = options[:only_rows]
    else
      rows = (2..@file.last_row)
    end
    headers = options[:headers]||@file.row(1)
    rows.each do |row_number|
      row_data = Hash[[headers, @file.row(row_number)].transpose]
      yield(row_number,row_data)
    end
  end

  def create_logfile(name, headers)
    #create new file
    #Add header row
    #Save to logfile instance variable
  end

  def add_log(logfile_name, log)
    #Find logfile in instance variable
    #Get log params that match logfile headers
    log_params = log.with_indifferent_access.slice(logfile[:headers])
    #Add to logfile
    
  end

  private

  def progress_log
    # {id: self.object_id, }
  end

  def logging
    log = Log4r::Logger.new("CONTROLLERS")
    log.outputters << Log4r::RollingFileOutputter.new('controllers', :filename => "#{Rails.root}/log/payment_pending.log", :maxsize => 10000000, :max_backups => 5)
    log
  end
end