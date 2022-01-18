function find_col(column_info, table, default_index){
  col_index = default_index || 0
  if (column_info){
    if (typeof(column_info)=='string'){
      var col_match = table.find("th:contains('"+column_info+"'), th[name='"+column_info+"']")[0]
      if (typeof(col_match)=='object'){
        col_index = col_match.cellIndex}
    }
    else if (typeof(column_info)=='number'){
      var number_cols = $('th', table.find('thead')).length;
      if (0<column_info && column_info<number_cols){
        col_index = column_info
      }
    }
  }
  return col_index
}