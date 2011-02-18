package net.odoe.locator.helpers
{
	import com.esri.ags.Graphic;
	import com.esri.ags.tasks.Locator;
	import com.esri.ags.tasks.supportClasses.AddressCandidate;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncResponder;
	import mx.utils.StringUtil;
	
	import net.odoe.locator.factories.DefaultSymbols;
	import net.odoe.locator.factories.IGraphicSymbols;

	[Event(name="geocodeComplete",type="flash.events.Event")]
	/**
	 * This component is the workhorse of the BatchGeocoder.
     * Will process an ArrayCollection of addresses and send them
     * one-by-one to a GeocodeServer and process the results.
     * 
	 * @author rrubalcava
	 */
	public class BatchLocator extends EventDispatcher
	{
		public static const ADDRESSCOLLECTION_CHANGE_EVENT:String = "addressCollectionChange";
		public static const GEOCODE_COMPLETE:String = "geocodeComplete";
        
		protected static const ADDRESS_FOUND:String = "AddressFound";
		protected static const SCORE:String = "Score";
		
		/**
		 * Provide the address fields and GeocodeServer URL
		 * @param addressFields
		 * @param locatorURL
		 */
		public function BatchLocator(addressFields:Object, locatorURL:String)
		{
			_addressField = addressFields["Address"];
			_cityField = addressFields["City"];
			_stateField = addressFields["State"];
			_zipField = addressFields["Zip"];
			_countryField = addressFields["Country"];
			_locatorURL = locatorURL;
		}
        
		protected var _addressCollection:ArrayCollection;
		
		[Event(name="addressCollectionChange",type="flash.events.Event")]
		public function get addressCollection():ArrayCollection
		{
			return _addressCollection;
		}
        
		public function set addressCollection(value:ArrayCollection):void
		{
			if (_addressCollection != value)
			{
				_addressCollection = value;
				dispatchEvent(new Event(ADDRESSCOLLECTION_CHANGE_EVENT));
			}
		}
        
		protected var _addressField:String;
		protected var _cityField:String;
		protected var _countryField:String;
		protected var _graphicsCollection:ArrayCollection;
		protected var _locatorURL:String;
		protected var _stateField:String;
		protected var _zipField:String;
		
		protected var addressCount:int;
		protected var checkCount:int;
		
		/**
		 * Handles the results of the Geocoder
		 * @param candidates
		 * @param token
		 */
		protected function addressResults_handler(candidates:Array, token:Object = null):void
		{
			if (candidates.length > 0)
			{
				var addrCandidate:AddressCandidate = candidates[0];
				loadGraphicsCollection(addrCandidate);
				var _add:String = StringUtil.trim(String(addrCandidate.address));
				token[ADDRESS_FOUND] = _add;
				token[SCORE] = addrCandidate.score;
				addressCollection.refresh();
			}
			checkCount++;
			if (checkCount == addressCount)
			{
				dispatchEvent(new Event(GEOCODE_COMPLETE));
			}
		}
		
		/**
		 * Will parse the item passed to this class and prepare it for
         * use with ArcGIS Server geocoder.
		 * @param item
		 * @return 
		 */
		protected function buildAddressObject(item:Object):Object
		{
			var address:String = "";
			var city:String = "";
			var state:String = "";
			var zip:String = "";
			var country:String = "USA";
			
			if (_addressField.length > 0)
				address = item[_addressField];
			if (_cityField.length > 0)
				city = item[_cityField];
			if (_stateField.length > 0)
				_stateField = item[_stateField];
			if (_zipField.length > 0)
				zip = item[_zipField];
			if (_countryField.length > 0)
				country = item[_countryField];
			
            // You may need to modify these fields to work with your
            // particular locator service
			return {
					Address:address,
					City:city,
					State:state,
					Zip:zip,
					Country:country
				};
		}
		
		/**
		 * Initialize the geocode process
		 */
		protected function geocodeAddress():void
		{
			var locator:Locator = new Locator(_locatorURL);
			_graphicsCollection = new ArrayCollection();
			locator.showBusyCursor = true;
			var outFields:Array = ["*"];
			var item:Object;
			for each (item in addressCollection)
			{
				var params:Object = buildAddressObject(item);
				locator.addressToLocations(params, outFields, new AsyncResponder(addressResults_handler, onFault, item));
			}
		}
		
		/**
		 * Will load the address result as a graphic to the graphics layer
		 * @param candidate
		 */
		protected function loadGraphicsCollection(candidate:AddressCandidate):void
		{
            // Depending on your services, you may or may not need to use the WebMercatorUtil.geographicToWebMercator() function.
			var g:Graphic = new Graphic(WebMercatorUtil.geographicToWebMercator(candidate.location), null, candidate.attributes);
            //var g:Graphic = new Graphic(candidate.location, null, candidate.attributes);
            var symbol:IGraphicSymbols = new DefaultSymbols();
            g.symbol = symbol.getSymbol(g);
			var toolTip:String = "Address: " + String(candidate.address) + "\nScore: " + String(candidate.score);
			g.toolTip = toolTip;
			_graphicsCollection.addItem(g);
		}
		
		/**
		 * Fault handler
		 * @param info
		 * @param token
		 */
		protected function onFault(info:Object, token:Object = null):void
		{
			trace("Geocode Failure: \n" + info.toString());
		}
		
		/**
		 * Returns the results in an ArrayCollection of graphics.
		 * @return 
		 */
		public function getGraphics():ArrayCollection
		{
			return _graphicsCollection;
		}
		
		/**
		 * Will process an array of addresses to geocode
		 * @param addresses
		 */
		public function locateAddresses(addresses:Array):void
		{
			addressCount = 0;
			checkCount = 0;
			addressCollection = new ArrayCollection(addresses);
			addressCount = addressCollection.length;
			var item:Object;
			for each (item in addressCollection)
			{
				item[SCORE] = 0.00;
				item[ADDRESS_FOUND] = "";
				addressCollection.refresh();
			}
			geocodeAddress();
		}
	}
}