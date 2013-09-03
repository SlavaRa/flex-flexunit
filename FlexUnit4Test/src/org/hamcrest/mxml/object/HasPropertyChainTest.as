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
package org.hamcrest.mxml.object
{
    import org.hamcrest.mxml.AbstractMXMLMatcherTestCase;

    public class HasPropertyChainTest extends AbstractMXMLMatcherTestCase
    {
        private var matcher:HasPropertyChain;
        
        [Before]
        public function createMatcher():void 
        {
            matcher = new HasPropertyChain();
            matcher.propertyChain = "one.two.three";
            matcher.value = 4;
        }
        
        [Test]
        public function hasDescription():void 
        {
            assertDescription("has property chain \"one.two.three\" with a value of <4>", matcher);
        }
        
        [Test]
        public function matchedIsTrueIfTargetMatches():void
        {
            matcher.target = { one: { two: { three: 4 } } };
            
            assertMatched("matched if target matches", matcher);
        }
        
        [Test]
        public function matchedIsFalseIfTargetIsMissingLink():void 
        {
            matcher.target = { one: { two: {} } };
            
            assertNotMatched("not matched if target is missing link", matcher);
        }
        
        [Test]
        public function matchedIsFalseIfTargetHasUnexpectedValue():void 
        {
            matcher.target = { one: { two: { three: 5 } } };
            
            assertNotMatched("not matched if target has unexpected value", matcher);
        }
        
        [Test]
        public function mismatchDescriptionIsNullIfTargetMatches():void 
        {
            matcher.target = { one: { two: { three: 4 } } };
            
            assertMatchedMismatchDescription(matcher);
        }
        
        [Test]
        public function mismatchDescriptionIsSetIfTargetIsMissingLink():void 
        {
            matcher.target = { one: { two: {} } };
            
            assertMismatchDescription("missing property \"three\"", matcher);
        }
        
        [Test]
        public function mismatchDescriptionIsSetIfTargetHasUnexpectedValue():void 
        {
            matcher.target = { one: { two: { three: 5 } } };
            
            assertMismatchDescription("was <5>", matcher);
        }
    }
}