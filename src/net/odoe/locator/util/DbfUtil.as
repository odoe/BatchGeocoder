package net.odoe.locator.util {
import flash.utils.ByteArray;

import org.vanrijkom.dbf.DbfField;
import org.vanrijkom.dbf.DbfHeader;
import org.vanrijkom.dbf.DbfRecord;
import org.vanrijkom.dbf.DbfTools;

public class DbfUtil {
	public static function toArray(dbf:ByteArray):Array {
		var dbfArray:Array = [];
		if (dbf) {
			var dbfHeader:DbfHeader = new DbfHeader(dbf);
			var i:int = 0;
			var x:int = dbfHeader.recordCount;
			
			for (i; i < x; i++) {
				var dbfRecord:DbfRecord = DbfTools.getRecord(dbf, dbfHeader, i);
				var item:Object = {};
				var field:DbfField;
				for each (field in dbfHeader.fields) {
					item[field.name] = dbfRecord.values[field.name];
				}
				dbfArray.push(item);
			}
		}
		return dbfArray;
	}
}
}