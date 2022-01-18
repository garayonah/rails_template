module Admin
  #AdminBase Controller has some actions that can be used by many different controllers
  #It has code for actions: index, show, new, create, edit, update, deactivate, reactivate, pages
  class BaseController < AdminController
    #privilege_access redirects users back to the home page if they do not have the required privileges
    #privilege_access is defined in application_controller
    #the resource_name is used here to change the privilege needed depending in the controller
    #eg. in UsersController
    # privilege_access("view_#{resource_name}") => privilege_access("view_user")
    before_action(only: [:index, :show, :pages]) { privilege_access("view_#{resource_name}") }
    before_action(only: [:new, :create, :upload_new, :upload_create]) { privilege_access("create_#{resource_name}") }
    before_action(only: [:edit, :update]) { privilege_access("edit_#{resource_name}") }
    before_action(only: [:deactivate, :reactivate]) { privilege_access("edit_#{resource_name}") }
    helper_method :default_attributes

    #add 'super' to actions in other controllers to use the default actions here in the base controller
    #eg.
    #def index
    # super
    #end

    #'variable||=value' means if the variable is not yet defined, it is set to 'value'
    #if variable is defined, it will not change

    #Shows a list of objects in a DataTable
    def index
      not_found if resource_class.index_columns.blank?
      #By default, the datatable type will decided using the local_pagination_limit setting
      #if the number of rows in the class is over the setting value, the datatable will be server based
      if @datatable_type.blank? && resource_class.count>Setting.find_by_name('local_pagination_limit').value.to_i
        #Server-side Pagination uses the 'pages' action to one page of the datatable at a time
        @datatable_type = 'server'
      else
        #Local Pagination loads all the objects at once to the datatable
        @datatable_type = 'local'
        @objects||=resource_class.where(query_params)
      end
      
      #default_attributes generates a hash with details about how each attributes should be handled
      @attributes||=default_attributes(only: resource_class.index_columns)
    end

    #Shows fuller details of a single object
    # params:
    #   id - id attribute of object
    def show
      not_found if resource_class.show_columns.blank?
      @object||=resource_object
      @attributes||= default_attributes(only: resource_class.show_columns)
    end

    #Form for generating a new object, submitted to :create action
    def new
      @attributes||=default_attributes(only: resource_class.new_columns)
    end

    #Generates new object using details from :new action
    #params: -depends on table
    def create
      not_found if resource_class.new_columns.blank?
      begin
        flash.update(params.to_unsafe_hash)
        object_params||= params.permit(resource_class.new_columns)
        #object_params.update(params.slice(*resource_class.column_names))

        object_params[:created_by_id] = session_user.id if resource_class.column_names.include? 'created_by_id'

        created_object = resource_class.create!(object_params)

        flash[:success_notice] = "#{resource_name} was successfully created!"
        redirect_to(action: "show", id: created_object.id) and return
      rescue Exception=>e
        flash[:error_notice] = e.message
        redirect_to action: "new" and return
      end
    end

    #Form for updating an object, submitted to :update action
    #params: -depends on table
    #   id - id attribute of object
    def edit
      not_found if resource_class.edit_columns.blank?
      @object||=resource_object
      @attributes||=default_attributes(only: resource_class.edit_columns, except: ['status', 'id', 'created_at', 'updated_at', 'created_by_id', 'updated_by_id'])
    end

    #Updates object using details from :edit action
    #params: -depends on table
    #   id - id attribute of object
    def update
      not_found if resource_class.edit_columns.blank?
      begin
        object_params||= params.permit(resource_class.edit_columns).to_h.with_indifferent_access
        object_params[:updated_by_id] = session_user.id if resource_class.column_names.include? 'updated_by_id'
        
        resource_object.update!(object_params)

        flash[:success_notice] = "#{resource_name.titleize} was successfully updated!"
        redirect_to(action: "show", id: resource_object.id) and return
      rescue Exception=>e
        flash[:error_notice] = e.message
        redirect_to(action: "edit", id: resource_object.id) and return
        redirect_to action: "new" and return
      end
    end

    #Updates 'status' attribute of object to 'inactive'
    #   id - id attribute of object
    def deactivate
      not_found if !resource_class.edit_columns.include?'status'
      #defined in app/models/concerns/common_methods.rb
      resource_object.deactivate
      flash[:success_notice] = "#{resource_name.titleize} was successfully deactivated"
      redirect_to action: 'show'
    end

    #Updates 'status' attribute of object to 'active'
    #   id - id attribute of object
    def reactivate
      not_found if !resource_class.edit_columns.include?'status'
      #defined in app/models/concerns/common_methods.rb
      resource_object.reactivate
      flash[:success_notice] = "#{resource_name.titleize} was successfully reactivated"
      redirect_to action: 'show'
    end

    #Sends object list data to server-based DataTables
    def pages
      not_found if resource_class.index_columns.blank?
      #render json: params and return
      length = params[:length]||10; start = params[:start]||0
      order = "#{params[:order_column]} #{params[:order_dir]}"
      columns = {}
      default_filter = (params[:default_filter]||{}).to_hash
      if params[:columns]
        params[:columns].values.each{|column| columns[column[:name]] = column}
      else
        resource_class.column_names.each{|column| columns[column] = {name: column, data: column}}
      end
      #columns = resource_class.column_names
      #raise Exception.new(default_filter.class)
      total = resource_class.where(default_filter).reorder(order)
      filtered = total
      sql_query_list = []

      #Filter Dropdown Search Columns
      if params[:search_cols_dropdown].present?
        sql_query_list<<params[:search_cols_dropdown].to_unsafe_hash.map{|column_name, value|"CAST(#{column_name} AS TEXT) = '#{value}'"}.join(' AND ')
      end

      #Filter Date Search Columns
      if params[:search_cols_date].present?
        params[:search_cols_date].each do |column_name, value|
          sql_query_list<<"CAST(#{column_name} AS DATE) >= '#{value[:start_date].to_date.strftime('%Y-%m-%d')}'" if value[:start_date].present?
          sql_query_list<<"CAST(#{column_name} AS DATE) <= '#{value[:end_date].to_date.strftime('%Y-%m-%d')}'" if value[:end_date].present?
        end
      end

      #Filter Min Amount Search Columns
      if params[:search_cols_amount].present?
        params[:search_cols_amount].each do |column_name, value|
          # if !resource_class.type_for_attribute(column_name).number?#conversion if number_range isn't numeric
          #   column_name = "CAST(SUBSTRING(#{column_name} FROM '\\d+') AS FLOAT)"
          # end
          sql_query_list<<"CAST(#{column_name} AS FLOAT) >= '#{value[:min]}'" if value[:min].present?
          sql_query_list<<"CAST(#{column_name} AS FLOAT) <= '#{value[:max]}'" if value[:max].present?
        end
      end

      #Filter Text Search Columns
      if params[:search_cols].present?
        sql_query_list<<params[:search_cols].to_unsafe_hash.map{|column_name, value|"lower(CAST(#{column_name} AS TEXT)) LIKE lower('%#{value}%')"}.join(' AND ')
      end

      #Filter Text Search (All Columns)
      if params[:search_value].present?
        searchable_columns = columns.select{|name,data| data[:searchable].to_s=='true'}.map{|name,data| data[:data]}
        sql_query_list<<searchable_columns.map{|column|"lower(CAST(#{column} AS TEXT)) LIKE lower('%#{params[:search_value]}%')"}.join(' OR ')
      end

      #Add style attributes
      sql_query = sql_query_list.map{|sq|"(#{sq})"}.join(' AND ')
      filtered = filtered.where(sql_query) if !sql_query_list.empty?
      objects = filtered.offset(start).limit(length)
      data = objects.map{|object|
        row = {}
        columns.each{|column_name, column_data|
          row[column_data[:data]] = (object.send(column_data[:data]) rescue object[column_data[:data]]).to_s
          if column_name!=column_data[:data]
            row[column_data[:method]] = (object.send(column_data[:method]) rescue object[column_data[:data]]).to_s
          end
        }
        row[:view] = "<a class='fa fa-eye' href='/admin/#{resource_name.tableize}/#{object.id}'>View</a>"
        row[:edit] = "<a class='fa fa-edit' href='/admin/#{resource_name.tableize}/#{object.id}/edit'>Edit</a>"
        row
      }
      result = {
        draw: params[:draw],
        recordsTotal: total.size,
        recordsFiltered: filtered.size,
        sql: filtered.to_sql,
        #query: sql_query,
        query: CGI.escape(sql_query),
        order: order,
        #params: params,
        data: data,
      }
      render json: result
    end

    def export
      not_found if resource_class.index_columns.blank?
      @attributes||=default_attributes(except: ['id', 'updated_by_id', 'created_by_id', 'updated_at'])
      csv_columns = @attributes.map{|k,v|[v[:title], v[:method]]}.to_h
      #raise Exception.new(csv_columns.inspect)
      query = CGI.unescape(params[:query]) rescue nil
      objects = resource_class.where(query).reorder(params[:order])
      #send_data resource_to_csv(objects, resource_class.column_names), filename: "#{resource_name.titleize} List.csv"
      send_data objects.to_csv(csv_columns), filename: "#{resource_name.titleize} List.csv"
    end

    #Form for uploading a list of objects, submitted to :upload_create action
    def upload_new
    end

    #Generates new object using details from :upload_new action
    #params: -depends on table
    #   file - spreadsheet file containing list of objects
    def upload_create
      begin
        #Make sure file was sent
        if params[:file].blank?
          flash[:error_notice] = "File Missing"
          redirect_to action: 'upload_new' and return
        end

        #File Object
        file = params[:file]
        #File Object => 'filename.xls'
        filename = file.original_filename
        #'filename.xls' => 'filename'
        basename = File.basename(filename,File.extname(filename))

        #Initialize spreadsheet file
        spreadsheet = Roo::Spreadsheet.open(file.path)
        #Get list of headers
        header_row = spreadsheet.row(1).map{|c|c.to_s.parameterize.tableize.singularize}
        
        columns = resource_class.column_names & header_row
        belongs_to = resource_class.belongs_to_names.map(&:to_s) & header_row
        
        # rows = []

        # (2..spreadsheet.last_row).each do |i|
        #   begin
        #     row = Hash[[header_row, spreadsheet.row(i)].transpose].with_indifferent_access
        #     row_columns = row.slice(*columns)
        #     belongs_to.each{|b|
        #       row_columns[b] = resource_class.association_class(b).find_by('lower(name) LIKE ?', row[b].to_s.downcase)
        #     }
        #     resource_class.create!(row_columns)
        #     rows<<[i, 'Successful']
        #   rescue Exception=>e
        #     rows<<[i, e.message]
        #   end
        # end

        # results = CSV.generate(headers: true) do |csv|
        #   csv << ['Row', 'Message']
        #   rows.each do |row|
        #     csv << row
        #   end
        # end


        results = CSV.generate(headers: true) do |csv|
          csv << ['Row', 'Message']
          (2..spreadsheet.last_row).each do |i|
            begin
              row = Hash[[header_row, spreadsheet.row(i)].transpose].with_indifferent_access
              row_columns = row.slice(*columns)
              belongs_to.each{|b|
                row_columns[b] = resource_class.association_class(b).find_by('lower(name) LIKE ?', row[b].to_s.downcase)
              }
              resource_class.create!(row_columns)
              csv << [i, 'Successful']
            rescue Exception=>e
              csv << [i, e.message]
            end
          end
        end
        
        send_data results, filename: "#{basename}-upload result(#{Time.now}).csv"
        return
      rescue Exception=>e
        flash[:error_notice] = e.message
        logging.error(e.message)
        redirect_to action: 'upload_new' and return
      end
    end

    def report
      if params[:report_type]=='comparison' && params[:x].present? && params[:y].present?
        @comparison_report_params = params.slice(:x, :y, :x_groups, :y_groups, :sum).select{|k,v|v.present?}.to_unsafe_hash.symbolize_keys
        if @comparison_report_params[:x].present? & @comparison_report_params[:y].present?
          @comparison_report = ModelReports.compare_columns(resource_class, @comparison_report_params)
        end
      elsif params[:report_type]=='standard' && params[:column].present?
        @standard_report_params = {column: params[:x], sum: params[:sum]}
        @standard_report = ModelReports.standard(resource_class, @standard_report_params.symbolize_keys)
      else
        @standard_report_params = {column: (params[:column]||resource_class.index_columns.first), group_by: params[:group_by], value: params[:value]}
        @standard_report = ModelReports.highcharts(resource_class, @standard_report_params.symbolize_keys)
      end
    end

    private

    #Returns a hash with details about how to handle attributes in the views
    #{"name"=>{"title"=>"Name", "method"=>"name", "attribute_style"=>"font-weight: bold", "required"=>true}, "status"=>{"title"=>"Status", "method"=>"status", "value_style"=>{"active"=>"background:#add8e6", "inactive"=>"background:#f08080"}, "dropdown"=>["active", "inactive"]}}
    def default_attributes(except: nil, only: nil)
      attributes = {}.with_indifferent_access
      column_names = resource_class.column_names
      column_names = column_names - except.map(&:to_s) if except
      column_names = column_names & only.map(&:to_s) if only
      column_names.each{|c|
        #title: How the name of the attribute will be displayed
        #method: The function used to get value of the attribute
        attribute = {title: c.titleize, method: c}
        
        #required: This attribute is required when creating or updating
        attribute.update(required: true) if c=='name'
        
        #attribute_style: CSS style used for all values of this attribute
        attribute.update(attribute_style: 'font-weight: bold') if c=='name'
        attribute.update(attribute_style: 'text-transform: uppercase;') if c=='status'
        
        #value_style: CSS style depending on value of attribute(overrides :attribute_style)
        attribute.update(value_style: {active: 'background:#add8e6', inactive: 'background:#ef8f8f'}) if c=='status'
      
        #dropdown: Options used in dropdown selects
        attribute.update(dropdown: ['active', 'inactive']) if c=='status'
      
        #dropdown: Options used in dropdown selects
        attribute.update(boolean: true) if resource_class.columns_hash[c].type==:boolean
        
        #attribute.update(method: c.sub('_id', '_name')) if c.ends_with? '_id'
        
        if c=='location_id'
          extended_name_sql = "concat(parents_locations.name,': ',locations.name)"
          attribute.update(method: 'location_name_extended', dropdown: Location.districts.includes(:parent).pluck(extended_name_sql, :id))
        elsif ['user_id', 'created_by_id', 'updated_by_id'].include?c
          name_sql = "concat(users.firstname,' ',users.lastname)"
          attribute.update(method: c.sub('_id', '_name'), dropdown: User.pluck(name_sql, :id))
        elsif (c.ends_with?"_id" and resource_class.association_class(c.chomp('_id')))
          #e.g 'company_type_id' => 'company_type'
          association_name = c.chomp('_id')
          association_model = resource_class.association_class(association_name)
          #Get the Class e.g 'company_type' => CompanyType
          if association_model.column_names.include? 'name'
            attribute.update(method: c.sub('_id', '_name'))
            attribute.update(dropdown: association_model.pluck(:name, :id))
          else
            attribute.update(dropdown: association_model.pluck(:id))
          end
        end

        if ['created_at', 'updated_at'].include? c or c.ends_with?"_date"
          attribute.update(calendar: 'date')
        end

        attributes[c] = attribute
      }
      return attributes
    end

    def query_params
      params.permit(resource_class.column_names)
    end
   
    def update_params
      params.permit(resource_class.edit_columns)
    end
  end
end