package net.odoe.locator.helpers {
import com.esri.ags.Graphic;
import com.esri.ags.tasks.Locator;
import com.esri.ags.tasks.supportClasses.AddressCandidate;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.rpc.AsyncResponder;
import mx.utils.StringUtil;

[Event(name="geocodeComplete",type="flash.events.Event")]
public class BatchLocator extends EventDispatcher {
	public static const ADDRESSCOLLECTION_CHANGE_EVENT:String = "addressCollectionChange";
	public static const GEOCODE_COMPLETE:String = "geocodeComplete";
	private static const ADDRESS_FOUND:String = "AddressFound";
	private static const SCORE:String = "Score";
	
	public function BatchLocator(addressFields:Object, locatorURL:String) {
		_addressField = addressFields["Street"];
		_cityField = addressFields["City"];
		_locatorURL = locatorURL;
	}
	
	private var _addressCollection:ArrayCollection;
	private var _addressField:String;
	private var _cityField:String;
	private var _dbf:ByteArray;
    private var _graphicsCollection:ArrayCollection;
	private var _locatorURL:String;
	
	private var addressCount:int;
	private var checkCount:int;
	
	private function addressResults_handler(candidates:Array, token:Object = null):void {
		if (candidates.length > 0) {
			var addrCandidate:AddressCandidate = candidates[0];
            loadGraphicsCollection(addrCandidate);
			var _add:String = StringUtil.trim(String(addrCandidate.address));
			token[ADDRESS_FOUND] = _add;
			token[SCORE] = addrCandidate.score;
			addressCollection.refresh();
		}
		checkCount++;
		if (checkCount == addressCount) {
			dispatchEvent(new Event(GEOCODE_COMPLETE));
		}
	}
	
    private function loadGraphicsCollection(candidate:AddressCandidate):void {
        var g:Graphic = new Graphic(candidate.location, null, candidate.attributes);
        var toolTip:String = "Address: " + String(candidate.address) + "\nScore: " + String(candidate.score);
        g.toolTip = toolTip;
        _graphicsCollection.addItem(g);
    }
    
	private function geocodeAddress():void {
		var locator:Locator = new Locator(_locatorURL);
        _graphicsCollection = new ArrayCollection();
        locator.showBusyCursor = true;
		var outFields:Array = ["*"];
		var item:Object;
		for each (item in addressCollection) {
			var params:Object = {Street:item[_addressField], City:item[_cityField]};
			locator.addressToLocations(params, outFields, new AsyncResponder(addressResults_handler, onFault, item));
		}
	}
	
	private function onFault(info:Object, token:Object = null):void {
		trace("Geocode Failure: \n" + info.toString());
	}
	
    [Event(name="addressCollectionChange",type="flash.events.Event")]
	public function get addressCollection():ArrayCollection {
		return _addressCollection;
	}
	
	public function set addressCollection(value:ArrayCollection):void {
		if (_addressCollection != value) {
			_addressCollection = value;
			dispatchEvent(new Event(ADDRESSCOLLECTION_CHANGE_EVENT));
		}
	}
	
    public function getGraphics():ArrayCollection {
        return _graphicsCollection;
    }
    
	public function locateAddresses(addresses:Array):void {
		addressCount = 0;
		checkCount = 0;
        addressCollection = new ArrayCollection(addresses);
        addressCount = addressCollection.length;
        var item:Object;
        for each (item in addressCollection) {
            item[SCORE] = 0.00;
            item[ADDRESS_FOUND] = "";
            addressCollection.refresh();
        }
        geocodeAddress();
	}
}
}