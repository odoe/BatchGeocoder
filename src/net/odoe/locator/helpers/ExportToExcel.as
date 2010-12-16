package net.odoe.locator.helpers {
import com.as3xls.xls.ExcelFile;
import com.as3xls.xls.Sheet;

import flash.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.logging.ILogger;

public class ExportToExcel implements IExportToExcel {
    public function ExportToExcel() {
    }

    protected var fields:Array;

    protected function dispose(event:Event):void {
        event.currentTarget.removeEventListener(Event.COMPLETE, onFileSaveComplete_handler);
        event.currentTarget.removeEventListener(Event.CANCEL, onFileReferenceCancel_handler);
        fields = [];
    }

    protected function insertRecordInSheet(row:uint, sheet:Sheet, record:Object, count:uint):void {
        var i:uint = 0;
        for (i; i < count; i += 1) {
            var x:uint = 0;
            for each (var field:String in fields) {
                for each (var val:String in record) {
                    if (record[field] && record[field].toString() == val)
                        sheet.setCell(row, x, val);
                }
                x++;
            }
        }
    }

    protected function onFileReferenceCancel_handler(event:Event):void {
        this.dispose(event);
    }

    protected function onFileSaveComplete_handler(event:Event):void {
        this.dispose(event);
    }

    public function collectionToExcel(collection:ArrayCollection):void {
        var sheet:Sheet = new Sheet();
        var rowCount:uint = collection.length;
        var dg:DataGrid = new DataGrid();
        dg.dataProvider = collection;
        var colCount:uint = dg.columnCount;
        sheet.resize(rowCount + 1, colCount);

        var col:Array = dg.columns;
        var i:uint = 0;
        fields = [];
        for each (var field:DataGridColumn in col) {
            fields.push(field.dataField.toString());
            sheet.setCell(0, i, field.dataField.toString());
            i++;
        }

        var r:uint = 0;
        for (r; r < rowCount; r++) {
            var rec:Object = collection.getItemAt(r);
            this.insertRecordInSheet(r + 1, sheet, rec, colCount);
        }

        var xls:ExcelFile = new ExcelFile();
        xls.sheets.addItem(sheet);
        dg = null;
        var bytes:ByteArray = xls.saveToByteArray();
        var fr:FileReference = new FileReference();
        fr.addEventListener(Event.CANCEL, onFileReferenceCancel_handler);
        fr.addEventListener(Event.COMPLETE, onFileSaveComplete_handler);
        fr.save(bytes, "export.xls");
    }
}
}