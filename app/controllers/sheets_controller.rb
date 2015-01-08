class SheetsController < ApplicationController
    
  def index
    @sheets = connection.request('get', '/sheets' )
  end

  # def show
  #     sheet = connection.request('get', "/sheet/#{params[:id]}")
  #     jobslip_index = getRowIndex "jobslip printed", sheet
  #     rows = sheet["rows"]
  #     rows = rows.delete_if { |e| e["cells"][jobslip_index]["value"] if e["cells"][jobslip_index]} 
  #      headers = sheet["columns"].map{|e| e["title"]}
  #      @data = []
  #      rows.each do |row|
  #           @data << (headers.zip row["cells"].map{|e| e["value"]}).to_h
  #      end 
  #     @data
  # end

  def select_columns
     sheet = connection.request('get', "/sheet/#{params[:id]}")
     @columns = sheet['columns'].map { |e| e["title"] }
  end

  def go
    @columns = params[:columns]
      sheet = connection.request('get', "/sheet/#{params[:id]}")
      jobslip_index = getRowIndex "jobslip printed", sheet
      rows = sheet["rows"]
      rows = rows.delete_if { |e| e["cells"][jobslip_index]["value"] if e["cells"][jobslip_index]} 
      headers = sheet["columns"].map{|e| e["title"]}
       @data = []
       rows.each do |row|
            @data << (headers.zip row["cells"].map{|e| e["value"]}).to_h
       end 
       @filter_data = []
      @data.each do |row|
            @filter_data  << row.select{|w| @columns.include?(w)}
      end
  end


  private

    def connection 
      @connection ||= Smartsheet.new(session[:smartsheet_token])
    end

    def getRowIndex rowName, sheet
       sheet["columns"].find { |e| e["title"]== rowName  }["index"] || -1
    end
end