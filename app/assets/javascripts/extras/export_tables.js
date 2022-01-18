//http://jsfiddle.net/qxLn3h86/48/

function tablesToExcel(tables, sheetNames, filename, appname) {
  var uri = 'data:application/vnd.ms-excel;base64,'
  , tmplWorkbookXML = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'
    + '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Author>Axel Richter</Author><Created>{created}</Created></DocumentProperties>'
    + '<Styles>'
    + '<Style ss:ID="Currency"><NumberFormat ss:Format="Currency"></NumberFormat></Style>'
    + '<Style ss:ID="Date"><NumberFormat ss:Format="Medium Date"></NumberFormat></Style>'
    + '</Styles>' 
    + '{worksheets}</Workbook>'
  , tmplWorksheetXML = '<Worksheet ss:Name="{nameWS}"><Table>{rows}</Table></Worksheet>'
  , tmplCellXML = '<Cell{attributeStyleID}{attributeFormula}><Data ss:Type="{nameType}">{data}</Data></Cell>'
  
    var ctx = "";
    var workbookXML = "";
    var worksheetsXML = "";
    var rowsXML = "";

    for (var i = 0; i < tables.length; i++) {
      if (!tables[i].nodeType) tables[i] = document.getElementById(tables[i]);
      for (var j = 0; j < tables[i].rows.length; j++) {
        var row = tables[i].rows[j];
        rowsXML += '<Row>'
        for (var k = 0; k < row.cells.length; k++) {
          var cell = row.cells[k];
          var dataType = cell.getAttribute("data-type");
          var dataStyle = cell.getAttribute("data-style");
          var dataValue = cell.getAttribute("data-value");
          //dataValue = (dataValue)?dataValue:cell.innerHTML;
          dataValue = (dataValue)?dataValue:$.trim(cell.textContent);
          var dataFormula = cell.getAttribute("data-formula");
          dataFormula = (dataFormula)?dataFormula:(appname=='Calc' && dataType=='DateTime')?dataValue:null;
          ctx = {  attributeStyleID: (dataStyle=='Currency' || dataStyle=='Date')?' ss:StyleID="'+dataStyle+'"':''
                 , nameType: (dataType=='Number' || dataType=='DateTime' || dataType=='Boolean' || dataType=='Error')?dataType:'String'
                 , data: (dataFormula)?'':dataValue
                 , attributeFormula: (dataFormula)?' ss:Formula="'+dataFormula+'"':''
                };
          rowsXML += format(tmplCellXML, ctx);
        }
        rowsXML += '</Row>'
      }
      ctx = {rows: rowsXML, nameWS: sheetNames[i] || 'Sheet' + i};
      worksheetsXML += format(tmplWorksheetXML, ctx);
      rowsXML = "";
    }

    ctx = {created: (new Date()).getTime(), worksheets: worksheetsXML};
    workbookXML = format(tmplWorkbookXML, ctx);
    
    console.log(workbookXML);

    var link = document.createElement("A");
    link.href = uri + base64(workbookXML);
    link.download = filename || 'Workbook.xls';
    link.target = '_blank';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};

//replace parts of text with hash values
//e.g. format('hello {x}', {x: 'world'}) returns 'hello world'
function format(s, c) {
  return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; })
}

//Encode XML to add uri
function base64(s){
  return window.btoa(unescape(encodeURIComponent(s)))
}