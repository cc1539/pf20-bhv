
public class Camera {
  
  private PMatrix3D look;
  private float view_x;
  private float view_y;
  private PVector position;
  private PVector rotation;
  
  public Camera() {
    position = new PVector();
    rotation = new PVector();
    look = new PMatrix3D();
    look.reset();
  }
  
  public void setView(float x, float y) {
    view_x = x;
    view_y = y;
  }
  
  public void updateShader(PShader shader) {
    updateLook();
    shader.set("cameraPos",position);
    shader.set("cameraLook",look,true);
    shader.set("cameraView",view_x,view_y);
  }
  
  public void updateLook() {
    look.reset();
    look.rotateZ(rotation.z);
    look.rotateX(rotation.x);
    look.rotateY(rotation.y);
  }
  
  public void turnX(float angle) {
    rotation.x += angle;
  }
  
  public void turnY(float angle) {
    rotation.y += angle;
  }
  
  public void walk(float speed) {
    position.x += look.m20*speed;
    position.y += look.m21*speed;
    position.z += look.m22*speed;
  }
  
  public void fly(float speed) {
    position.x += look.m10*speed;
    position.y += look.m11*speed;
    position.z += look.m12*speed;
  }
  
  public void strafe(float speed) {
    position.x += look.m00*speed;
    position.y += look.m01*speed;
    position.z += look.m02*speed;
  }
  
}
