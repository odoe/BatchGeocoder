package test.net.odoe.locator.helpers {
import flash.events.Event;
import flash.utils.ByteArray;

import flexunit.framework.Assert;
import flexunit.framework.TestCase;

import mx.collections.ArrayCollection;

import net.odoe.locator.helpers.BatchLocator;
import net.odoe.locator.util.DbfUtil;

import org.flexunit.asserts.assertNull;

public class BatchLocatorTest extends TestCase {
	protected var batchLocator:BatchLocator;
	
	[Embed(source="honeycutt.dbf", mimeType="application/octet-stream")]
	protected var address_dbf:Class;
	
	[Before]
	override public function setUp():void {
        var fields:Object = {
            Street: "STREET_ADD",
            City: "JURISDICTI"
        };
		batchLocator = new BatchLocator(fields, "http://208.179.133.118/ArcGIS/rest/services/LACSD_Landfill_HO/GeocodeServer");
	}
	
	[After]
	override public function tearDown():void {
		batchLocator = null;
	}
	
	[Test(async)]
	public function canLocatorParseData():void {
		var byteArray:ByteArray = ByteArray(new address_dbf());
		assertNull(batchLocator.addressCollection);
		batchLocator.addEventListener(BatchLocator.GEOCODE_COMPLETE, addAsync(verifyEvent, 25000, null, verifyNoEvent));
        var temp:Array = DbfUtil.toArray(byteArray);
		batchLocator.locateAddresses(temp);
	}
	
	private function verifyNoEvent(event:Event, token:Object = null):void {
		fail("Unexpected Event.COMPLETE from BatchLocator instance");
	}
	
	private function verifyEvent(token:Object = null):void {
		assertNotNull(batchLocator.addressCollection);
	}
}
}