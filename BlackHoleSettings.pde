
public class BlackHoleSettings {
  
  private PVector blackHolePos;
  private float blackHoleSpin;
  private float blackHoleRadius;
  
  private float accretionDiskRadius;
  private float accretionDiskBrightness;
  private float accretionDiskThickness;
  private color accretionDiskOuterColor;
  private color accretionDiskInnerColor;
  private float accretionDiskDensity;
  
  private float minCloudStep;
  private float maxCloudStep;
  private int[] cloudOctaves;
  
  private boolean portal;
  private float time;
  
  private PShader render;
  
  public void link(PShader render) {
    this.render = render;
  }
  
  void setBlackHolePos(PVector value) { blackHolePos=value; render.set("blackHolePos",value); }
  void setBlackHoleSpin(float value) { blackHoleSpin=value; render.set("blackHoleSpin",value); }
  void setBlackHoleRadius(float value) { blackHoleRadius=value; render.set("blackHoleRadius",value); }
  
  void setAccretionDiskRadius(float value) { accretionDiskRadius=value; render.set("accretionDiskRadius",value); }
  void setAccretionDiskBrightness(float value) { accretionDiskBrightness=value; render.set("accretionDiskBrightness",value); }
  void setAccretionDiskThickness(float value) { accretionDiskThickness=value; render.set("accretionDiskThickness",value); }
  void setAccretionDiskOuterColor(float r, float g, float b) { accretionDiskOuterColor=color(r,g,b); render.set("accretionDiskOuterColor",r,g,b); }
  void setAccretionDiskInnerColor(float r, float g, float b) { accretionDiskInnerColor=color(r,g,b); render.set("accretionDiskInnerColor",r,g,b); }
  void setAccretionDiskDensity(float value) { accretionDiskDensity=value; render.set("accretionDiskDensity",value); }
  
  void setMinCloudStep(float value) { minCloudStep=value; render.set("minCloudStep",value); }
  void setMaxCloudStep(float value) { maxCloudStep=value; render.set("maxCloudStep",value); }
  void setCloudOctaves(int...value) { cloudOctaves=value; render.set("cloudOctaves",value); render.set("cloudOctaveCount",value.length); }
  
  void setTime(float value) { time=value; render.set("time",value); }
  
  void togglePortal() {
    render.set("portal",portal=!portal);
  }
  
  public void updateDependents() {
    float rMin = blackHoleRadius*3.;
    float rMax = accretionDiskRadius;
    render.set("rMin",rMin);
    render.set("rMax",rMax);
    render.set("rMin2",rMin*rMin);
    render.set("rMax2",rMax*rMax);
    render.set("adt",accretionDiskThickness*2.);
  }
  
}
