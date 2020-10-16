
boolean[] input = new boolean[256];

PShader render;
PShader bloom;
Camera camera;
BlackHoleSettings bhs = new BlackHoleSettings();

float global_time;
boolean running = true;
PGraphics canvas;
boolean auto_orbit;

void setup() {
  
  size(840,840,P2D);
  noSmooth();
  colorMode(RGB,1,1,1);
  
  canvas = createGraphics(width,height,P2D);
  canvas.noSmooth();
  
  render = loadShader("render.glsl");
  render.set("windowSize",(float)width,(float)height);
  render.set("skymap",loadImage("skymap.jpg"));
  render.set("maxIterations",256);
  render.set("cameraJitter",1e-3);
  
  bhs.link(render);
  bhs.setBlackHolePos(new PVector(0,0,0));
  bhs.setBlackHoleSpin(-0.1);
  bhs.setBlackHoleRadius(300);
  bhs.setAccretionDiskRadius(4000);
  bhs.setAccretionDiskBrightness(2e-4);
  bhs.setAccretionDiskThickness(300);
  bhs.setAccretionDiskOuterColor(2.25,0.81,0.36);
  bhs.setAccretionDiskInnerColor(0.2,0.36,2.25);
  bhs.setAccretionDiskDensity(0.2);
  bhs.setMinCloudStep(10);
  bhs.setMaxCloudStep(160);
  bhs.setCloudOctaves(2,6,8,9,20);
  bhs.updateDependents();
  
  camera = new Camera();
  camera.setView(1,1);
  camera.position.z -= 50000;
  camera.position.y += 500; 
  
  bloom = loadShader("bloom.glsl");
  //bloom.set("range",5);
  //bloom.set("amount",0.1);
  //bloom.set("threshold",0.0);
  bloom.set("canvas",canvas);
  
  camera.rotation.z = .2;
}

void keyPressed() {
  if(keyCode>=0 && keyCode<input.length) {
    input[keyCode] = true;
  }
  switch(key) {
    case 't': {
      running = !running;
    } break;
    case 'q': {
      auto_orbit = !auto_orbit;
    } break;
    /*
    case 'p': {
      bhs.togglePortal();
    } break;
    */
  }
}

void keyReleased() {
  if(keyCode>=0 && keyCode<input.length) {
    input[keyCode] = false;
  }
}

void draw() {
  
  if(auto_orbit) {
    float angle = bhs.blackHoleRadius*1e3/pow(camera.position.mag(),2);
    PMatrix3D turn = new PMatrix3D();
    turn.reset();
    turn.rotateY(angle);
    turn.mult(camera.position,camera.position);
    camera.rotation.y -= angle;
  }
  
  if(running) {
    global_time += 5;
  }
  
  float turn_speed = 0.008;
  float move_speed = 300;
  if(mousePressed) {
    if(mouseButton==RIGHT) {
      camera.turnX(-(mouseY-pmouseY)*turn_speed);
      camera.turnY(-(mouseX-pmouseX)*turn_speed);
    } else {
      if(keyPressed) {
        float value = (float)mouseX/width;
        switch(key) {
          case 'b': bhs.setAccretionDiskBrightness(value*0.1); break;
          case 'c': 
            bhs.setAccretionDiskRadius(value*1e5);
            //bhs.setAccretionDiskThickness(value*1e3);
            //bhs.setAccretionDiskBrightness(3e-4/value);
          break;
          case 'g': bhs.setBlackHoleRadius(value*1e4); break;
          case 'r': bhs.setBlackHoleSpin(value*1e2); break;
          case 'j': render.set("cameraJitter",value*.1); break;
        }
        bhs.updateDependents();
      }
    }
  }
  if(input[16]) { camera.fly(-move_speed); }
  if(input[32]) { camera.fly( move_speed); }
  if(input['w'-32]) { camera.walk( move_speed); }
  if(input['s'-32]) { camera.walk(-move_speed); }
  if(input['d'-32]) { camera.strafe( move_speed); }
  if(input['a'-32]) { camera.strafe(-move_speed); }
  
  camera.updateShader(render);
  bhs.setTime(global_time);
  canvas.filter(render);
  filter(bloom);
  //colorMode(RGB,255,255,255);
  //tint(255,200);
  //image(canvas,0,0);
  
  surface.setTitle("FPS: "+frameRate);
}
