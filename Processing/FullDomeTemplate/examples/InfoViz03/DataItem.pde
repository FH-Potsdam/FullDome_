class DataItem {
  VerletParticle position;
  Vec3D destPosition;
  String title;
  float speed = .4;
  DataItem(VerletParticle position_, String title_) {
    position = position_;
    destPosition = new Vec3D(position.x, position.y, position.z);
    title = title_;
  }
  
  void update() {
    // move to destPosition
    position.addSelf(
      (destPosition.x - position.x) * speed,
      (destPosition.y - position.y) * speed,
      (destPosition.z - position.z) * speed
    );
  }
}
