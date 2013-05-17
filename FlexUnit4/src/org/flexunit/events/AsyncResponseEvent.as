package org.flexunit.events {
	import flash.events.Event;
	
	import mx.rpc.IResponder;
	
	/**
	 * An AsyncResponseEvent is event that is fired when an asynchronous test has recieved a response
	 * from an <code>IAsyncTestTresponder</code>.
	 */
	public class AsyncResponseEvent extends Event {
		public static var RESPONDER_FIRED:String = "responderFired";
		
		public var originalResponder:*;
		public var methodHandler : Function;
		public var status:String;
		public var data:Object;
		
		/**
		 * Constructor.
		 *
		 * This class has all of the properties of the event class in addition to the
		 * originalResponder, status, and data properties.
		 *
		 * @param type The event type; indicates the action that triggered the event.
		 *
		 * @param bubbles Specifies whether the event can bubble
		 * up the display list hierarchy.
		 *
		 * @param cancelable Specifies whether the behavior
		 * associated with the event can be prevented.
		 *
		 * @param originalResponder The responder that originally responded to the async event.
		 *
		 * @param status The status of the asyncronous response.
		 *
		 * @param data The data that was returned from the async event, usually the data or the info from the fault.
		 *
		 */
		public function AsyncResponseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, originalResponder:*=null, status:String=null, data:Object=null ) {
			this.originalResponder = originalResponder;
			this.status = status;
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Called by the framework to facilitate any requisite event bubbling
		 *
		 * @inheritDoc
		 */
		override public function clone():Event {
			return new AsyncResponseEvent( type, bubbles, cancelable, originalResponder, status, data );
		}
	}
}