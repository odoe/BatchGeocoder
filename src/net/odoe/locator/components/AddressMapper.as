package net.odoe.locator.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.supportClasses.SkinnableComponent;
	[Event(name="addressFieldsChange",type="flash.events.Event")]
	[Event(name="fieldCollectionChange",type="flash.events.Event")]
	/**
	 * This component will map the fields of an object
     * to the fields used for Geocoding purposes
     * 
	 * @author rrubalcava
	 */
	public class AddressMapper extends SkinnableComponent
	{
		public static const ADDRESSFIELDS_CHANGE_EVENT:String = "addressFieldsChange";
		public static const FIELDCOLLECTION_CHANGE_EVENT:String = "fieldCollectionChange";
        
		public function AddressMapper()
		{
			super();
		}
		private var _addressFields:Object;
		
		[Bindable(event="addressFieldsChange")]
        
		public function get addressFields():Object
		{
			return _addressFields;
		}
		
		public function set addressFields(value:Object):void
		{
			if (_addressFields != value)
			{
				_addressFields = value;
				dispatchEvent(new Event(ADDRESSFIELDS_CHANGE_EVENT));
			}
		}
		
		[SkinPart(required="true")]
		public var btnSubmit:Button;
		
		[SkinPart(required="true")]
		public var ddlAddressField:DropDownList;
		
		[SkinPart(required="true")]
		public var ddlCityField:DropDownList;
		
		[SkinPart(required="true")]
		public var ddlCountryField:DropDownList;
		
		[SkinPart(required="true")]
		public var ddlStateField:DropDownList;
		
		[SkinPart(required="true")]
		public var ddlZipField:DropDownList;
		
		private var _fieldCollection:ArrayCollection;
		
		[Bindable(event="fieldCollectionChange")]
		public function get fieldCollection():ArrayCollection
		{
			return _fieldCollection;
		}
		
		public function set fieldCollection(value:ArrayCollection):void
		{
			if (_fieldCollection != value)
			{
				_fieldCollection = value;
				dispatchEvent(new Event(FIELDCOLLECTION_CHANGE_EVENT));
			}
		}
		
		/**
		 * Will assign the address fields based on what the user has selected.
		 * @param event
		 */
		protected function btnSubmit_clickHandler(event:MouseEvent):void
		{
			var aField:String = "";
			var cField:String = "";
			var sField:String = "";
			var zField:String = "";
			var cyField:String = "";
			if (ddlAddressField.selectedIndex >-1)
				aField = StringUtil.trim(String(ddlAddressField.selectedItem));
			if (ddlCityField.selectedIndex >-1)
				cField = StringUtil.trim(String(ddlCityField.selectedItem));
			if (ddlStateField.selectedIndex >-1)
				sField = StringUtil.trim(String(ddlStateField.selectedItem));
			if (ddlZipField.selectedIndex >-1)
				zField = StringUtil.trim(String(ddlZipField.selectedItem));
			if (ddlCountryField.selectedIndex >-1)
				cyField = StringUtil.trim(String(ddlCountryField.selectedItem));
			
			addressFields =
				{
					Address: aField,
					City: cField,
					State: sField,
					Zip: zField,
					Country: cyField
				};
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			switch (instance)
			{
				case btnSubmit:
					btnSubmit.addEventListener(MouseEvent.CLICK, btnSubmit_clickHandler, false, 0, true);
					break;
				case ddlAddressField:
					ddlAddressField.dataProvider = fieldCollection;
					break;
				case ddlCityField:
					ddlCityField.dataProvider = fieldCollection;
					break;
				case ddlStateField:
					ddlStateField.dataProvider = fieldCollection;
					break;
				case ddlZipField:
					ddlZipField.dataProvider = fieldCollection;
					break;
				case ddlCountryField:
					ddlCountryField.dataProvider = fieldCollection;
					break;
				default:
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if (instance == btnSubmit)
				btnSubmit.removeEventListener(MouseEvent.CLICK, btnSubmit_clickHandler);
		}
	}
}