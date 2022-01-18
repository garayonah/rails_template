// //yarn add install datatables.net datatables.net-bs4
// var DataTable = require('datatables.net');
// require( 'datatables.net-buttons' );

// //yarn add datatables.net-buttons datatables.net-buttons-bs4
// require( 'datatables.net-buttons/js/buttons.colVis.js' ); // Column visibility
// require( 'datatables.net-buttons/js/buttons.html5.js' );  // HTML 5 file export
// require( 'datatables.net-buttons/js/buttons.flash.js' );  // Flash file export
// require( 'datatables.net-buttons/js/buttons.print.js' );  // Print view button

// // $.fn.dataTable = DataTable;
// // $.fn.dataTableSettings = DataTable.settings;
// // $.fn.dataTableExt = DataTable.ext;
// // DataTable.$ = $;
var DataTable = require('datatables.net-bs4');
require( 'datatables.net-buttons-bs4' );
//yarn add datatables.net-responsive datatables.net-responsive-bs4
require( 'datatables.net-responsive-bs4' );
 
$.fn.dataTable = DataTable;
$.fn.dataTableSettings = DataTable.settings;
$.fn.dataTableExt = DataTable.ext;
DataTable.$ = $;
 
$.fn.DataTable = function ( opts ) {
    return $(this).dataTable( opts ).api();
};