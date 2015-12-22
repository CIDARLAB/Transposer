public class Xposer {
  boolean crossed = false;
  Pump outside;
  Pump inside;

  public Xposer(Pump outside, Pump inside) {
    this.outside = outside;
    this.inside = inside;
  }

  public void cross(int uStepsMove) {
    outside.dispense(uStepsMove, true);
    inside.dispense(uStepsMove, false);
    crossed = true;
  }

  public void straight(int uStepsMove) {
    outside.dispense(uStepsMove, false);
    inside.dispense(uStepsMove, true);
    crossed = false;
  }

  public boolean getCrossedStatus() { return crossed; }
}  
