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
package org.flexunit.experimental.theories {
	import flex.lang.reflect.Field;
	import flex.lang.reflect.Klass;
	
	import org.flexunit.constants.AnnotationConstants;
	import org.flexunit.experimental.runners.statements.TheoryAnchor;
	import org.flexunit.internals.dependency.ExternalDependencyResolver;
	import org.flexunit.internals.dependency.IExternalDependencyResolver;
	import org.flexunit.internals.dependency.IExternalRunnerDependencyWatcher;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runner.external.IExternalDependencyRunner;
	import org.flexunit.runners.BlockFlexUnit4ClassRunner;
	import org.flexunit.runners.model.FrameworkMethod;
	
	/**
	 * The <code>Theories</code> runner is a runner that will run theory test methods.  In order for a theory to properly run,
	 * a test class must have a method marked as a theory method that contains one or more parameters.  The type of each parameter
	 * must have a static data point or an array of data points that correspond that correspond to that type.
	 * 
	 * <pre>
	 * 
	 * [DataPoints]
	 * [ArrayElementType("String")]
	 * public static var stringValues:Array = ["one","two","three","four","five"];
	 * 
	 * [DataPoint]
	 * public static var values1:int = 2;
	 * 
	 * 
	 * [Theory]
	 * public function testTheory(name:String, value:int):void {
	 * 	//Do something
	 * }
	 * 
	 * </pre>
	 */
	public class Theories extends BlockFlexUnit4ClassRunner implements IExternalDependencyRunner {

		/**
		 * @private
		 */
		private var dr:IExternalDependencyResolver;

		/**
		 * @private
		 */
		private var _dependencyWatcher:IExternalRunnerDependencyWatcher;

		/**
		 * @private
		 */
		private var _externalDependencyError:String;

		/**
		 * @private
		 */
		private var externalError:Boolean = false;
		
		/**
		 * Constructor.
		 * 
		 * @param klass The test class that is to be executed by the runner.
		 */
		public function Theories( klass:Class ) {
			super( klass );

			dr = new ExternalDependencyResolver( klass, this );
			dr.resolveDependencies();
		}

		/**
		 * Setter for a dependency watcher. This is a class that implements IExternalRunnerDependencyWatcher
		 * and watches for any external dependencies (such as loading data) are finalized before execution of
		 * tests is allowed to commence.  
		 * 		 
		 * @param value An implementation of IExternalRunnerDependencyWatcher
		 */
		public function set dependencyWatcher( value:IExternalRunnerDependencyWatcher ):void {
			_dependencyWatcher = value;
			
			if ( value && dr ) {
				value.watchDependencyResolver( dr );	
			}
		}

		/**
		 * 
		 * Setter to indicate an error occured while attempting to load exteranl dependencies
		 * for this test. It accepts a string to allow the creator of the external dependency
		 * loader to pass a viable error string back to the user.
		 * 
		 * @param value The error message
		 * 
		 */
		public function set externalDependencyError( value:String ):void {
			externalError = true;
			_externalDependencyError = value;
		}

		/**
		 * @inheritDoc
		 */
		override protected function collectInitializationErrors( errors:Array ):void {
			super.collectInitializationErrors(errors);
	
			validateDataPointFields(errors);
		}
		
		/**
		 * Validates all fields in a test class an ensure that they are all static.
		 * 
		 * @param errors An array of errors that has been encountered during the initialization process.  If
		 * a field is not static, an error will be added to this array.
		 */
		private function validateDataPointFields( errors:Array ):void {
			var klassInfo:Klass = new Klass( testClass.asClass );

			for ( var i:int=0; i<klassInfo.fields.length; i++ ) {
				if ( !( klassInfo.fields[ i ] as Field ).isStatic ) {
					errors.push( new Error("DataPoint field " + ( klassInfo.fields[ i ] as Field ).name + " must be static") );
				}
			}
		}
		
		/**
		 * Adds to <code>errors</code> for each method annotated with <code>Test</code> or
		 * <code>Theory</code> that is not a public, void instance method.
		 */
		override protected function validateTestMethods( errors:Array ):void {
			var method:FrameworkMethod;
			var methods:Array = computeTestMethods();

			for ( var i:int=0; i<methods.length; i++ ) {
				method = methods[ i ];
				method.validatePublicVoid( false, errors );
			}
		}
		
		/**
		 * If an element is contained in the removeElements array and the other array, remove
		 * that element from the other array.
		 * 
		 * @param array The array that will have elements removed from it if a match is found.
		 * @param removeElements The array that contains elements to remove from the other array.
		 */
		private function removeFromArray( array:Array, removeElements:Array ):void {
			for ( var i:int=0; i<array.length; i++ ) {
				for ( var j:int=0; j<removeElements.length; j++ ) {
					if ( array[ i ] == removeElements[ j ] ) {
						array.splice( i, 1 );
					}
				}
			}
		}
		
		/**
		 * Returns the methods that run tests and theories.  The tests
		 * will be located at the begining of the returned array while 
		 * the theories will be present at the end of the array.
		 */
		override protected function computeTestMethods():Array {
			var testMethods:Array = super.computeTestMethods();
			var theoryMethods:Array = testClass.getMetaDataMethods( AnnotationConstants.THEORY );
			
			removeFromArray( testMethods, theoryMethods );
			testMethods = testMethods.concat( theoryMethods );

			return testMethods;
		}
		
		/**
		 * Returns a <code>TheoryAnchor</code> for the given theory method in the test class.
		 * 
		 * @param method The theory method that is to be tested.
		 * 
		 * @return a <code>TheoryAnchor</code> for the provided <code>FrameworkMethod</code>.
		 */
		override protected function methodBlock( method:FrameworkMethod ):IAsyncStatement {
			return new TheoryAnchor( method, testClass );
		}
	}
}