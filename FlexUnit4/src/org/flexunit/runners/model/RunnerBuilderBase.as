/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.flexunit.runners.model {
	import flash.utils.Dictionary;
	
	import org.flexunit.internals.runners.ErrorReportingRunner;
	import org.flexunit.internals.runners.InitializationError;
	import org.flexunit.runner.IRequest;
	import org.flexunit.runner.IRunner;

	/**
	 * The <code>RunnerBuilderBase</code> is used as a base by other runner builders in FlexUnit4.  It
	 * provides basic logic for the handling of constructing <code>IRunner</code>s for children of a
	 * provided test class.  These children in turn may have children that will also need 
	 * corresponding <code>IRunners</code>.<br/>
	 * 
	 * The <code>RunnerBuilderBase</code>contains logic ensuring that a parent class does not reference 
	 * itself or that a child class does not reference the parent, preventing a potential infinite loop.
	 * 
	 * @see org.flexunit.internals.builders.AllDefaultPossibilitiesBuilder
	 */
	public class RunnerBuilderBase implements IRunnerBuilder {
		/**
		 * @private
		 */
		private var parents:Dictionary = new Dictionary( true );

		/**
		 * Returns a boolean value indicating if this builder will be able to handle the testClass or not
		 * 
		 * @param testClass The class to test to determine an <code>IRunner</code>.
		 * 
		 * Returns false, forcing any new subclasses of RunnerBuilderBase to override this method.
		 */
		public function canHandleClass( testClass:Class):Boolean {
			return false;
		}
		/**
		 * Returns an <code>IRunner</code> that can safely run the provided <code>testClass</code>.
		 * If no suitable <code>IRunner</code> can be found, a value of <code>null</code> is returned.
		 * 
		 * @param testClass The class to for which to determine an <code>IRunner</code>.
		 * 
		 * @return an <code>IRunner</code> that can run the <code>testClass</code>.
		 */
		public function safeRunnerForClass( testClass:Class ):IRunner {
			try {
				return runnerForClass(testClass);
			} catch ( error:Error ) {
				return new ErrorReportingRunner(testClass, error );
			}

			return null;
		}
		
		/**
		 * Constructs and returns a list of <code>IRunner</code>s, one for each child class in
		 * <code>children</code>.  Care is taken to avoid infinite recursion:
		 * this builder will throw an exception if it is requested for another
		 * runner for <code>parent</code> before this call completes.
		 * 
		 * @param parent The parent class that contains the <code>children</code>.
		 * @param children The child classes for which to find <code>IRunner</code>.
		 * 
		 * @return a list of <code>IRunner</code>s, one for each child class.
		 */
		public function runners( parent:Class, children:Array ):Array {
			addParent(parent);
	
			try {
				//TODO, verify this works the same way in AS
				return localRunners(children);
			} catch (e:Error){
				trace(e.toString());
			} finally {
				removeParent(parent);
			}
			
			return null;
		}
		
		/**
		 * Returns an <code>Array</code> of runner that can run the provided <code>children</code>.
		 * 
		 * @param children An <code>Array</code> that consists of child classes of the parent class.
		 * 
		 * @return an <code>Array</code> of runners that can run the child classes.
		 */
		private function localRunners( children:Array ):Array {
			var runners:Array = new Array();
			
			//Determine what runner to use for each child
			for ( var i:int=0; i<children.length; i++ ) {
				//TODO: Verify this or look further into the world of JUnit for what I am missing.
				//To me this seems reasonable, but, then again there may be a better way
				//This is a bit of a hack. If we are already a request, then we simply return the associated runner
				//This should allow the mixing of Requests, classes and suites into a single construct
				var childRunner:IRunner;  
				var child:* = children[ i ];
				 
				if ( child is IRequest ) {
					childRunner = IRequest( child ).iRunner; 
				} else {
					childRunner = safeRunnerForClass( child );
				}
				
				if (childRunner != null)
					runners.push( childRunner );
			}
			return runners;
		}
		
		/**
		 * Returns an <code>IRunner</code> for a specific <code>testClass</code>.
		 * 
		 * @param testClass The test class for which to determine an <code>IRunner</code>.
		 * 
		 * @return an <code>IRunner</code> that will run the <code>testClass</code>.
		 */
		public function runnerForClass( testClass:Class ):IRunner {
			return null;
		}
		
		/**
		 * Checks to see if the <code>parent</code> is already in the parents dictionary; if it is, an exception is thrown,
		 * if not, the <code>parent</code> is added to the dictionary.
		 * 
		 * @param parent The parent class to add to the dictionary.
		 * 
		 * @throws org.flexunit.internals.runners.InitializationError Thrown if the <code>parent</code> is already in the 
		 * parents dictionary.  This could be caused due to a SuiteClass or a child SuiteClass containing itself.
		 */
		private function addParent( parent:Class ):Class {
			if ( parent ) {
				if ( parents[ parent ] ) {
					//this one already exists
					//need to catch and handle this error better than before, currently becomes an initialization
					//error which is incorrect
					throw new InitializationError( "Class " + parent + " (possibly indirectly) contains itself as a SuiteClass" );
				}
	
				parents[ parent ] = true;
			}
			
			return parent;
		}
		
		/**
		 * Removes the <code>parent</code> from the parents dictionary.
		 * 
		 * @param parent The parent class to remove from the dictionary.
		 */
		private function removeParent( parent:Class ):void {
			if ( parent ) {
				delete parents[ parent ];
			}
		}
		
		/**
		 * Constructor.
		 */
		public function RunnerBuilderBase() {
		}
	}
}