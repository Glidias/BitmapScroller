/*
 * The MIT License
 *
 * Original Author:  Jesse Freeman of FlashArtOfWar.com
 * Copyright (c) 2010
 * Class File: BitmapScrollerApp.as
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package
{
    import com.flashartofwar.BitmapScrollerHaxe;
    import com.flashartofwar.behaviors.EaseScrollBehavior;
    import com.flashartofwar.ui.Slider;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;

    import flash.text.TextField;

    import flash.text.TextFieldAutoSize;

    import net.hires.debug.Stats;

	[SWF( backgroundColor='0xFFFFFF', frameRate='120', width='480', height='800')]
    public class BitmapScrollerAppHaxe extends Sprite
    {

        private var preloadList:Array = ["image1.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image6.jpg","image7.jpg","image8.jpg","image9.jpg","image10.jpg","image11.jpg","image12.jpg","image13.jpg","image14.jpg","image15.jpg","image16.jpg","image17.jpg","image18.jpg","image19.jpg","image20.jpg","image21.jpg","image22.jpg","image23.jpg","image24.jpg","image25.jpg","image26.jpg","image27.jpg","image28.jpg","image29.jpg"];
        private var baseURL:String = "images/";
        private var currentlyLoading:String;
        private var loader:Loader = new Loader();
        private var bitmapScroller:BitmapScrollerHaxe;
        private var images:Vector.<BitmapData> = new Vector.<BitmapData>();
        private var easeScrollBehavior:EaseScrollBehavior;
        private var stats:Stats;
        private var isMouseDown:Boolean;
        private var slider:Slider;
        private var preloadStatus:TextField;
		private var defaultImgHeight:Number;
		
		private var isMobile:Boolean = false;

        /**
         *
         */
        public function BitmapScrollerAppHaxe(imgHeight:Number=800)
        {
			defaultImgHeight = imgHeight;
			
            configureStage();

            if (isMobile)
            {
                baseURL = "/" + baseURL;
            }

            preloadStatus = new TextField();
            preloadStatus.autoSize = TextFieldAutoSize.LEFT;
            preloadStatus.x = 10;
            preloadStatus.y = 10;
            preloadStatus.selectable = false;
            addChild(preloadStatus);
            
            preload();
        }

        /**
         *
         */
        private function configureStage():void
        {
            this.stage.align = StageAlign.TOP_LEFT;
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
        }

        /**
         *
         */
        protected function init():void
        {
            createBitmapScroller();
            createScrubber();
            createEaseScrollBehavior();
            createStats();

            if (!isMobile)
            {
                // Once everything is set up add stage resize listeners
                this.stage.addEventListener(Event.RESIZE, onStageResize);

                // calls stage resize once to put everything in its correct place
                onStageResize();
            }
            else
            {
                fingerTouch();
            }

            onStageResize();
            activateLoop();
        }

        /**
         *
         * @param event
         */
        private function onStageResize(event:Event = null):void
        {
            bitmapScroller.setWidth(  slider.width = stage.stageWidth );
            bitmapScroller.setHeight( stage.stageHeight  );
            slider.y = stage.stageHeight - slider.height - 20;

            slider.width -= 40;
            slider.x = 20;
        }

        /**
         *
         */
        private function createStats():void
        {
            stats = addChild(new Stats({ bg: 0x000000 })) as Stats;
            stats.y = 30;
        }

        /**
         *
         */
        private function activateLoop():void
        {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        /**
         *
         * @param event
         */
        private function onEnterFrame(event:Event):void
        {
            var percent:Number = slider.value / 100;
            var s:Number = bitmapScroller.getTotalLength();
            var t:Number = bitmapScroller.getWidth();

            easeScrollBehavior.targetX = percent * (s - t);
            //
            easeScrollBehavior.update();
            //
			bitmapScroller.scrollX = easeScrollBehavior.scrollX;
            bitmapScroller.render();
        }

        /**
         *
         */
        private function createEaseScrollBehavior():void
        {
            easeScrollBehavior = new EaseScrollBehavior(bitmapScroller, 0);
        }

        /**
         *
         */
        private function createScrubber():void
        {
            var sWidth:int = stage.stageWidth; 
            var sHeight:int = 10;
            var dWidth:int = 40;
            var corners:int = 5;
            if (isMobile)
            {
                sHeight = 20;
                dWidth = 60;
                corners = 10;
            }

            slider = new Slider(sWidth, sHeight, dWidth, corners);
            slider.y = stage.stageHeight - slider.height - 20;

            slider.addEventListener(Event.CHANGE, onSliderValueChange)
            addChild(slider);

        }

        private function onSliderValueChange(event:Event):void
        {
            trace("Slider Changed", slider.value);
        }

        /**
         *
         */
        private function createBitmapScroller():void
        {

            bitmapScroller = new BitmapScrollerHaxe();
			bitmapScroller.rotation = -270;
			bitmapScroller.scaleY = -1;
	
			// new implementation
            bitmapScroller.init(images, new Rectangle(0, 0, stage.stageWidth, defaultImgHeight) );
		
			
			for each( var bmpData:BitmapData in images) {
				bmpData.dispose();
			}
		
		
            addChild(bitmapScroller);
          //  bitmapScroller.setWidth( stage.stageWidth );
          //  bitmapScroller.setHeight( stage.stageHeight );

        }

        /**
         * Handles preloading our images. Checks to see how many are left then
         * calls loadNext or compositeImage.
         */
        protected function preload():void
        {

            if (preloadList.length == 0)
            {
                removeChild(preloadStatus);
                init();
            }
            else
            {
                loadNext();
                preloadStatus.text = preloadList.length > 0 ? preloadList.length + " Images Left To Load." : "Caching images. Please wait...";
            }
        }

        /**
         * Loads the next item in the prelaodList
         */
        private function loadNext():void
        {
            currentlyLoading = preloadList.shift();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

            loader.load(new URLRequest(baseURL + currentlyLoading));
        }

        /**
         *
         * @param event
         */
        private function onError(event:*):void
        {
            preloadStatus.text = event.text;
        }

        /**
         * Handles onLoad, saves the BitmapData then calls preload
         */
        private function onLoad(event:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoad);

            images.push(Bitmap(event.target.content).bitmapData);

            currentlyLoading = null;

            preload();
        }

        // This is for mobile touch support

        /**
         *
         */
        private function fingerTouch():void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        /**
         *
         * @param event
         */
        private function onMouseDown(event:MouseEvent):void
        {
            isMouseDown = true;
        }

        /**
         *
         * @param event
         */
        private function onMouseUp(event:MouseEvent):void
        {
            isMouseDown = false;
        }

        /**
         *
         * @param event
         */
        private function onMouseMove(event:MouseEvent):void
        {
            if (isMouseDown)
            {
                var percent:Number = (event.localX) / (stage.stageWidth) * 100;
                slider.value = percent;
            }
        }
    }
}