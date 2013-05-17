package flex.lang.reflect.builders {
	import flash.utils.Dictionary;
	
	import flex.lang.reflect.Method;
	import flex.lang.reflect.cache.ClassDataCache;
	import flex.lang.reflect.utils.MetadataTools;

	/**
	 * Object responsible for building method objects
	 * 
	 * @author mlabriola
	 * 
	 */	
	public class MethodBuilder {
		/**
		 * @private
		 */		
		private var classXML:XML;
		/**
		 * @private
		 */		
		private var inheritance:Array;
		/**
		 * @private
		 */		
		private var methodMap:Object;

		/**
		 * @private
		 */		
		private function buildMethod( methodData:XML, isStatic:Boolean ):Method {
			return new Method( methodData, isStatic );
		}
		
		/**
		 * @private
		 */
		private function buildMethods( parentBlock:XML, isStatic:Boolean = false ):Array {
			var methods:Array = new Array();
			var methodList:XMLList = new XMLList();
			
			if ( parentBlock ) {
				methodList = MetadataTools.getMethodsList( parentBlock );
			}
			
			for ( var i:int=0; i<methodList.length(); i++ ) {
				methods.push( buildMethod( methodList[ i ], isStatic ) );
			}
			
			return methods;
		}

		/**
		 * @private
		 */	
		private function addMetaDataToMethod( subClassMethod:Method, superClassMethod:Method ):void {
			var subMetaDataArray:Array = subClassMethod.metadata;
			var superMetaDataArray:Array = superClassMethod.metadata;
			
			for ( var i:int=0; i<superMetaDataArray.length; i++ ) {
				subMetaDataArray.push( superMetaDataArray[ i ] );
			}
		}

		/**
		 * @private
		 */	
		private function addMetaDataPerSuperClass( methodMap:Object, superXML:XML ):void {
			var methods:Array;
			var superMethod:Method;
			var instanceMethod:Method;

			if ( superXML.factory ) {
				methods = buildMethods( superXML.factory[ 0 ], false );
				
				for ( var i:int=0; i<methods.length; i++ ) {
					superMethod = methods[ i ] as Method;
					instanceMethod = methodMap[ superMethod.name ];
					
					if ( instanceMethod ) {
						//This one exists in the subclass, meaning it was overriden
						//Time to apply any metadata to the subclass method
						addMetaDataToMethod( instanceMethod, superMethod );							
					}
				}	
			}			
		}  

		/**
		 * Builds all Methods in this class, considering methods defined or overriden in this class and through inheritance		  
		 * @return An array of Method instances
		 * 
		 */		
		public function buildAllMethods():Array {
			var methods:Array = new Array();
			var method:Method;

			if ( classXML.factory ) {
				methods = methods.concat( buildMethods( classXML.factory[ 0 ], false ) );
			}

			methods = methods.concat( buildMethods( classXML, true ) );

			//If this object inherits from a class other than just Object
			if ( inheritance && ( inheritance.length > 1 ) ) {
				
				//Record all of these methods in an object so that we can check the inheritance hierarchy
				for ( var i:int=0; i<methods.length; i++ ) {
					method = methods[ i ] as Method;
					methodMap[ method.name ] = method;
				}

				for ( var j:int=0; j<inheritance.length; j++ ) {
					if ( inheritance[ j ] != Object ) {
						addMetaDataPerSuperClass( methodMap, ClassDataCache.describeType( inheritance[ j ] ) );
					}
				}
			}
			
			return methods;
		}
		
		/**
		 * Resposible for building method instances from XML descriptions 
		 * @param classXML
		 * @param inheritance
		 * 
		 */		
		public function MethodBuilder( classXML:XML, inheritance:Array ) {
			this.classXML = classXML;
			this.inheritance = inheritance; 
			
			methodMap = new Object();
		}
	}
}