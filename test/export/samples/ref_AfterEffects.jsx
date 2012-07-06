// Run this script from the Script Editor
function convertFrameToSeconds(layerWithFootage, frameValue)
  {
  		var comp = layerWithFootage.containingComp;
  		var rate = 1.0 / comp.frameDuration;
  		// Frames in AE are 0-based by default
  		return (frameValue) / rate;
  }


var layer0 = app.project.activeItem.layers.addNull();
layer0.name = "Parabolic_1_from_top_left";

var pos = layer0.property("Transform").property("Position");
pos.setValueAtTime(convertFrameToSeconds(layer0, 0), [0.00000,0.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 1), [96.00000,205.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 2), [192.00000,388.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 3), [288.00000,550.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 4), [384.00000,691.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 5), [480.00000,810.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 6), [576.00000,907.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 7), [672.00000,982.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 8), [768.00000,1036.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 9), [864.00000,1069.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 12), [1152.00000,1036.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 13), [1248.00000,982.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 14), [1344.00000,907.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 15), [1440.00000,810.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 16), [1536.00000,691.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 17), [1632.00000,550.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 18), [1728.00000,388.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 19), [1824.00000,205.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer0, 20), [1920.00000,0.00000]);

var layer1 = app.project.activeItem.layers.addNull();
layer1.name = "Parabolic_2_from_bottom_right";

var pos = layer1.property("Transform").property("Position");
pos.setValueAtTime(convertFrameToSeconds(layer1, 0), [1920.00000,1080.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 1), [1824.00000,874.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 2), [1728.00000,691.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 3), [1632.00000,529.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 4), [1536.00000,388.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 5), [1440.00000,270.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 6), [1344.00000,172.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 7), [1248.00000,97.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 8), [1152.00000,43.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 9), [1056.00000,10.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 12), [768.00000,43.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 13), [672.00000,97.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 14), [576.00000,172.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 15), [480.00000,270.00000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 16), [384.00000,388.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 17), [288.00000,529.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 18), [192.00000,691.20000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 19), [96.00000,874.80000]);
pos.setValueAtTime(convertFrameToSeconds(layer1, 20), [0.00000,1080.00000]);

var layer2 = app.project.activeItem.layers.addNull();
layer2.name = "SingleFrame_InTheMiddle";

var pos = layer2.property("Transform").property("Position");
pos.setValueAtTime(convertFrameToSeconds(layer2, 0), [970.00000,530.00000]);
