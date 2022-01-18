class ModelReports
  def self.highcharts(resource, column:, value: nil, group_by: nil, options: {})
    columns=options[:column_sets]||resource.distinct.pluck(column).sort
    report = {table: resource.table_name, column: column, column_sets: columns,
    value: value, group_by: group_by}.with_indifferent_access

    data = columns.map{|c|resource.where(column=> c).count} if value.blank?
    data = columns.map{|c|resource.where(column=> c).sum(value)} if value.present?
    report.update(totals: data)
    
    if group_by
      groups=options[:column_sets]||resource.distinct.pluck(group_by).sort
      column_data = groups.map{|group|
        groups=options[:group_sets]||resource.distinct.pluck(group_by).sort
        resource_grouped = resource.where(group_by=>group)
        data = columns.map{|c|resource_grouped.where(column=> c).count} if value.blank?
        data = columns.map{|c|resource_grouped.where(column=> c).sum(value)} if value.present?
        {name: group, data: data}
      }

      data = columns.map{|c|resource.where(column=> c).count/groups.count} if value.blank?
      data = columns.map{|c|resource.where(column=> c).sum(value)/groups.count} if value.present?
      report.update(averages: data)
    else
      column_data = [{name: 'totals', data: report[:totals]}]
    end
    report.update(column_data: column_data)
    return report
  end

  def self.compare_columns(resource, x:,y:, sum: nil, x_groups: nil, y_groups: nil)
    x_groups||=resource.distinct.pluck(x).sort
    y_groups||=resource.distinct.pluck(y).sort
    data = []
    x_groups.each do |x_group|
      y_groups.each do |y_group|
        matches = resource.where(x=>x_group, y=>y_group)
        if matches.present?
          result = {x=> x_group, y=> y_group, count: matches.size}.with_indifferent_access
          if sum
            result.update(sum: matches.sum(sum), average: (matches.sum(sum)/matches.size))
          end
          data<<result
        end
      end
    end
    
    return {x: x, y: y, x_groups: x_groups, y_groups: y_groups, sum: sum, data: data}.with_indifferent_access
  end
end