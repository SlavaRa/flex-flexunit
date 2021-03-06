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
package flexUnitTests.flexUnit4.suites.frameworkSuite.cases
{
	import org.flexunit.Assert;

    /**
     * @private
     */
	public class TestBeforeAfterOrder {
		protected static var setupOrderArray:Array = new Array();

		[Before]
		public function beginNoOrder():void {
			setupOrderArray.push( "beginNoOrder" );
		}

		[Before(order=1)]
		public function beginOne():void {
			setupOrderArray.push( "beginOne" );
		}

		[Before(order=70)]
		public function beginSeventy():void {
			setupOrderArray.push( "beginSeventy" );
		}

		[Before(order=2)]
		public function beginTwo():void {
			setupOrderArray.push( "beginTwo" );
		}

		[After]
		public function afterNoOrder() : void {
			setupOrderArray.push( "afterNoOrder" );
		}
		
		[After(order=1)]
		public function afterOne():void {
			setupOrderArray.push( "afterOne" );
		}

		[After(order=2)]
		public function afterTwo():void {
			setupOrderArray.push( "afterTwo" );
		}

		[After(order=8)]
		public function afterEight():void {
			setupOrderArray.push( "afterEight" );
		}

		[After(order=30)]
		public function afterThirty():void {
			setupOrderArray.push( "afterThirty" );
		}

		//This depends on the test order also working, so we should always run this test after the method order has been verified
		[Test(order=1)]
	    public function checkingBeforeOrder() : void {
	    	//4 begins
	    	if ( setupOrderArray.length == 4 ) {
	    		Assert.assertEquals( setupOrderArray[ 0 ], "beginNoOrder" );
	    		Assert.assertEquals( setupOrderArray[ 1 ], "beginOne" );
	    		Assert.assertEquals( setupOrderArray[ 2 ], "beginTwo" );
	    		Assert.assertEquals( setupOrderArray[ 3 ], "beginSeventy" );
	    	} else {
	    		Assert.fail("Incorrect number of begin calls");
	    	}
	    }

		[Test(order=2)]
	    public function checkingAfterOrder() : void {
	    	//4 begins
	    	//5 afters
	    	//4 more begins
	    	if ( setupOrderArray.length == 13 ) {
	    		Assert.assertEquals( setupOrderArray[ 4 ], "afterNoOrder" );
	    		Assert.assertEquals( setupOrderArray[ 5 ], "afterOne" );
	    		Assert.assertEquals( setupOrderArray[ 6 ], "afterTwo" );
	    		Assert.assertEquals( setupOrderArray[ 7 ], "afterEight" );
	    		Assert.assertEquals( setupOrderArray[ 8 ], "afterThirty" );
	    	} else {
	    		Assert.fail("Incorrect number of after calls");
	    	}
	    }

	}
}