# class ModelReports
#   def self.compare_columns(resource, x:,y:, sum: nil, x_groups: nil, y_groups: nil)
#     x_groups||=resource.distinct.pluck(x).sort
#     y_groups||=resource.distinct.pluck(y).sort
#     data = []
#     x_groups.each do |x_group|
#       y_groups.each do |y_group|
#         matches = resource.where(x=>x_group, y=>y_group)
#         if matches.present?
#           result = {x=> x_group, y=> y_group, count: matches.size}.with_indifferent_access
#           if sum
#             result.update(sum: matches.sum(sum), average: (matches.sum(sum)/matches.size))
#           end
#           data<<result
#         end
#       end
#     end
    
#     return {x: x, y: y, x_groups: x_groups, y_groups: y_groups, sum: sum, data: data}.with_indifferent_access
#   end

#   def self.standard(resource, column:, sum: nil, column_groups: nil)
#     column_groups||=resource.distinct.pluck(column).sort
#     data = []
#     column_groups.each do |column_group|
#       matches = resource.where(column=>column_group)
#       if matches.present?
#         result = {column=> column_group, count: matches.size}.with_indifferent_access
#         if sum
#           result.update(sum: matches.sum(sum), average: (matches.sum(sum)/matches.size))
#         end
#         data<<result
#       end
#     end
    
#     return {column: column, column_groups: column_groups, sum: sum, data: data}.with_indifferent_access
#   end
# end