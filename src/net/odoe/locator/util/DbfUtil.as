package net.odoe.locator.util
{
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	
	import org.vanrijkom.dbf.DbfField;
	import org.vanrijkom.dbf.DbfHeader;
	import org.vanrijkom.dbf.DbfRecord;
	import org.vanrijkom.dbf.DbfTools;
	
	/**
	 * This utility class will process a 
     * ByteArray of a loaded Excel file and convert
     * it to an Array that can be used in the application
     * 
	 * @author rrubalcava
	 */
	public class DbfUtil
	{
		/**
		 * Convert a ByteArray of an Excel file to a native Array
		 * @param dbf
		 * @return 
		 */
		public static function toArray(dbf:ByteArray):Array
		{
			var dbfArray:Array = [];
			if (dbf)
			{
				var dbfHeader:DbfHeader = new DbfHeader(dbf);
				var i:int = 0;
				var x:int = dbfHeader.recordCount;
				
				for (i; i < x; i++)
				{
					var dbfRecord:DbfRecord = DbfTools.getRecord(dbf, dbfHeader, i);
					var item:Object = {};
					var field:DbfField;
					for each (field in dbfHeader.fields)
					{
						item[field.name] = StringUtil.trim(dbfRecord.values[field.name]);
					}
					dbfArray.push(item);
				}
			}
			return dbfArray;
		}
	}
}