﻿package com.mega.core
{
    import flash.net.NetStream;
    import flash.display.Sprite;
    import flash.media.Video;
    import flash.media.StageVideo;
    import flash.events.StageVideoAvailabilityEvent;
    import flash.events.Event;
    import com.mega.data.PlayerData;
    import flash.media.StageVideoAvailability;
    import flash.events.StageVideoEvent;
    import flash.events.VideoEvent;
    import flash.geom.Rectangle;

    public class VideoHandler 
    {

        public static const ASPECT_RATIO_4_TO_3:String = "4:3";
        public static const ASPECT_RATIO_16_TO_9:String = "16:9";
        public static const ASPECT_RATIO_ORIGINAL:String = "original";
        private static const ALL_ASPECT_RATIOS:Array = [ASPECT_RATIO_ORIGINAL, ASPECT_RATIO_16_TO_9, ASPECT_RATIO_4_TO_3];

        private var _aspectRatio:String;
        private var _stream:NetStream;
        private var _classicVideoBackground:Sprite;
        private var _classicVideo:Video;
        private var _stageVideo:StageVideo;
        private var _stageVideoAvailable:Boolean;
        private var _stageVideoInUse:Boolean;
        private var _classicVideoInUse:Boolean;

        public function VideoHandler(_arg1:NetStream, _arg2:Video)
        {
            this._stream = _arg1;
            this._classicVideo = _arg2;
            this._classicVideo.smoothing = true;
            this._classicVideoBackground = new Sprite();
            this._classicVideoBackground.graphics.beginFill(0);
            this._classicVideoBackground.graphics.drawRect(0, 0, Main.getStage().stageWidth, Main.getStage().stageHeight);
            this._classicVideoBackground.graphics.endFill();
            this._classicVideoBackground.visible = false;
            Main.getInstance().addChildAt(this._classicVideoBackground, Main.getInstance().getChildIndex(_arg2));
            this._aspectRatio = ALL_ASPECT_RATIOS[0];
            Main.getStage().addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, this.onStageVideoAvailable);
            Main.getStage().addEventListener(Event.RESIZE, this.stageResizeHandler);
        }

        private function onStageVideoAvailable(_arg1:StageVideoAvailabilityEvent):void
        {
            this._stageVideoAvailable = ((PlayerData.getIgnoreStageVideo()) ? false : (_arg1.availability == StageVideoAvailability.AVAILABLE));
            if (this._stageVideoAvailable)
            {
                this.toggleStageVideo(true);
            }
            else
            {
                this.toggleStageVideo(false);
            };
        }

        private function stageResizeHandler(_arg1:Event):void
        {
            this.resize();
        }

        private function toggleStageVideo(_arg1:Boolean):void
        {
            if (_arg1)
            {
                if (this._stageVideo == null)
                {
                    this._stageVideoInUse = true;
                    this._stageVideo = Main.getStage().stageVideos[0];
                    this._stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, this.onStageVideoStateChange);
                    this._stageVideo.attachNetStream(this._stream);
                };
                if (this._classicVideoInUse)
                {
                    this._classicVideoInUse = false;
                    this._classicVideoBackground.visible = false;
                    this._classicVideo.clear();
                    this._classicVideo.removeEventListener(VideoEvent.RENDER_STATE, this.onVideoStateChange);
                };
            }
            else
            {
                if (this._stageVideo != null)
                {
                    this._stageVideoInUse = false;
                    this._stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE, this.onStageVideoStateChange);
                    this._stageVideo = null;
                };
                if (!this._classicVideoInUse)
                {
                    this._classicVideoInUse = true;
                    this._classicVideoBackground.visible = true;
                    this._classicVideo.addEventListener(VideoEvent.RENDER_STATE, this.onVideoStateChange);
                    this._classicVideo.attachNetStream(this._stream);
                };
            };
        }

        private function onVideoStateChange(_arg1:VideoEvent):void
        {
            this.resize();
        }

        private function onStageVideoStateChange(_arg1:StageVideoEvent):void
        {
            this.resize();
        }

        private function getVideoRect(_arg1:uint, _arg2:uint):Rectangle
        {
            var _local3:Rectangle = new Rectangle(0, 0, 0, 0);
            var _local4:uint = _arg1;
            var _local5:uint = _arg2;
            var _local6:Number = Math.min((Main.getStage().stageWidth / _local4), (Main.getStage().stageHeight / _local5));
            _local4 = (_local4 * _local6);
            _local5 = (_local5 * _local6);
            var _local7:uint = ((Main.getStage().stageWidth - _local4) >> 1);
            var _local8:uint = ((Main.getStage().stageHeight - _local5) >> 1);
            _local3.x = _local7;
            _local3.y = _local8;
            _local3.width = _local4;
            _local3.height = _local5;
            return (_local3);
        }

        public function resize():void
        {
            var _local1:Rectangle;
            this._classicVideoBackground.width = Main.getStage().stageWidth;
            this._classicVideoBackground.height = Main.getStage().stageHeight;
            if (this._stageVideoInUse)
            {
                switch (this._aspectRatio)
                {
                    case ASPECT_RATIO_ORIGINAL:
                        _local1 = this.getVideoRect(this._stageVideo.videoWidth, this._stageVideo.videoHeight);
                        break;
                    case ASPECT_RATIO_16_TO_9:
                        _local1 = this.getVideoRect(16, 9);
                        break;
                    case ASPECT_RATIO_4_TO_3:
                        _local1 = this.getVideoRect(4, 3);
                        break;
                };
                this._stageVideo.viewPort = _local1;
            }
            else
            {
                switch (this._aspectRatio)
                {
                    case ASPECT_RATIO_ORIGINAL:
                        _local1 = this.getVideoRect(this._classicVideo.videoWidth, this._classicVideo.videoHeight);
                        break;
                    case ASPECT_RATIO_16_TO_9:
                        _local1 = this.getVideoRect(16, 9);
                        break;
                    case ASPECT_RATIO_4_TO_3:
                        _local1 = this.getVideoRect(4, 3);
                        break;
                };
                this._classicVideo.width = _local1.width;
                this._classicVideo.height = _local1.height;
                this._classicVideo.x = _local1.x;
                this._classicVideo.y = _local1.y;
            };
        }

        public function setAspectRatio(_arg1:String):void
        {
            var _local2:Rectangle;
            switch (_arg1)
            {
                case ASPECT_RATIO_4_TO_3:
                    return;
                case ASPECT_RATIO_16_TO_9:
                    return;
                case ASPECT_RATIO_ORIGINAL:
                    return;
            };
        }

        public function getAspectRatio():String
        {
            return (this._aspectRatio);
        }

        public function getNextAspectRatio():String
        {
            var _local1:uint = (((ALL_ASPECT_RATIOS.indexOf(this._aspectRatio))==(ALL_ASPECT_RATIOS.length - 1)) ? 0 : (ALL_ASPECT_RATIOS.indexOf(this._aspectRatio) + 1));
            return (ALL_ASPECT_RATIOS[_local1]);
        }

        public function switchToNextAspectRatio():String
        {
            var _local1:uint = (((ALL_ASPECT_RATIOS.indexOf(this._aspectRatio))==(ALL_ASPECT_RATIOS.length - 1)) ? 0 : (ALL_ASPECT_RATIOS.indexOf(this._aspectRatio) + 1));
            this._aspectRatio = ALL_ASPECT_RATIOS[_local1];
            this.resize();
            return (this._aspectRatio);
        }

        public function getStageVideoInUse():Boolean
        {
            return (this._stageVideoInUse);
        }


    }
}//package com.mega.core
