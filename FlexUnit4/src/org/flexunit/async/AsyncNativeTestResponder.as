/package org.flexunit.async {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	
	import org.flexunit.events.AsyncResponseEvent;
	
	/** 
	 * The 'responderFired' event is fired when either a result or
	 * fault is dispatched.
	 */
	[Event(name="responderFired",type="net.digitalprimates.fluint.events.AsyncResponseEvent")]
	
	/**
	 * A respoder for asynchronous tests that contains result and fault handlers for the test succeeding or the test 
	 * failing to succeed.
	 */
	public class AsyncNativeTestResponder extends Responder implements IEventDispatcher {
		/**
		 * @private
		 */
		private var resultHandler : Function;		
		private var faultHandler : Function;
		private var eventDispatcher : EventDispatcher;
		/**
		 * Dispatches an AsyncResponseEvent with the orignalResponder, a "fault" status, and the provided info object.
		 * 
		 * @inheritDoc
		 *
		 */
		public function fault( info:Object ):void {
			var asyncResponseEvent : AsyncResponseEvent = new AsyncResponseEvent( AsyncResponseEvent.RESPONDER_FIRED, false, false, null, 'fault', info );
			asyncResponseEvent.methodHandler = faultHandler;
			dispatchEvent(asyncResponseEvent);
		}
		
		/**
		 * Dispatches an AsyncResponseEvent with the orignalResponder, a "result" status, and the provided info object.
		 * 
		 * @inheritDoc
		 */
		public function result( data:Object ):void {
			var asyncResponseEvent : AsyncResponseEvent = new AsyncResponseEvent( AsyncResponseEvent.RESPONDER_FIRED, false, false, null, 'result', data );
			asyncResponseEvent.methodHandler = resultHandler;
			dispatchEvent(asyncResponseEvent);
		}
		
		/**
		 * Constructor.
		 * 
		 * @param originalResponder The responder to be passed when the AsyncResponseEvent is dispatched.
		 */
		public function AsyncNativeTestResponder( resultHandler : Function, faultHandler : Function ) {
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.eventDispatcher = new EventDispatcher(this);
			super(result, fault);
		}

		//---------------------------------
		//   EventDispatcher methods
		//---------------------------------
		
		/**
		 * @private
		 */
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @private
		 */
		public function hasEventListener(type : String) : Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		/**
		 * @private
		 */
		public function dispatchEvent(event : Event) : Boolean
		{
			return eventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */
		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @private
		 */
		public function willTrigger(type : String) : Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
	}
}