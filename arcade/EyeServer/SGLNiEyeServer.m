classdef (Sealed) SGLNiEyeServer < ABSEyeServer
    
    properties ( Constant )
        eyelines = {'Dev1/ai0:1'};
        samplingRate = 1000; % Hz, tested up to 4000 Hz        
        vgain = [10 10]; % V
        screensize = [1680 1050]; % x y in px
    end
    
    properties ( Access = private )
        nidaqObj                
    end
    

  methods (Static)
        function this = launch
            persistent thisObj
            if isempty(thisObj) || ~isvalid(thisObj)
                thisObj = SGLNiEyeServer;
            end
            this = thisObj;
        end
    end

    methods (Access = private)
        function this = SGLNiEyeServer
            this = this@ABSEyeServer;              
            this.nidaqObj = mNIDAQ;
            this.nidaqObj.daqmxCreateAIVoltageChan(this.eyelines); % create channels
            this.nidaqObj.daqmxCfgSampClkTiming(this.samplingRate)
            
        end
    end

    methods
        
        function eyePosition = acquire_eye_position(this)
            analogInput = this.nidaqObj.daqmxReadAnalogF64(1);                    
            [xPx, yPx] = volts2pixels(analogInput(1),analogInput(2), ...
                this.vgain, this.screensize);
            eyePosition = [xPx yPx];
        end
        
        function initialize(this)
            this.nidaqObj.daqmxStartTask();
        end
        
        function stop(this)
            this.nidaqObj.daqmxStopTask();
        end
            
        function this = delete(this)
            delete(this.nidaqObj);
            delete(this.sharedMemory);
        end
    end
end
    
    
    
    
