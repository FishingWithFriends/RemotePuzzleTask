/*
 * Dart Game Sample
 */
part of remotepuzzletask;
/*
 * Dart Game Sample
*/

class TouchManager {
  
  /* Is the mouse currently down */
  bool mdown = false;
  
  /* Element that receives touch or mouse events */
  Element parent = null;
  
  /* A list of touch layers */
  List<TouchLayer> layers = new List<TouchLayer>();
   
  /* Bindings from event IDs to touchable objects */
  Map<int, TouchBinding> touch_bindings = new Map<int, TouchBinding>();
   
 
  
  TouchManager(){ 
  }
  
/*
 * Add a touch layer to the list
 */
  
  void addTouchLayer(TouchLayer layer) {
    layers.add(layer);
  }
   

/*
 * Remove a touch layer from the master list
 */
  void removeTouchLayer(TouchLayer layer) {
    layers.remove(layer);
  }
   
   
/*
 * See which layer wants to handle this touch
 */
  TouchBinding findTouchTarget(Contact tp) {
      for (int i=layers.length - 1; i >= 0; i--) {
        Touchable t = layers[i].findTouchTarget(tp);
        if (t != null) return new TouchBinding(layers[i], t);
      }
    return null;
  }
  
  
/*
 * The main class must call this method to enable mouse and touch input
 */ 
  void registerEvents(Element element) {
      parent = element;
     
      element.onMouseDown.listen((e) => _mouseDown(e));
      element.onMouseUp.listen((e) => _mouseUp(e));
      element.onMouseMove.listen((e) => _mouseMove(e));
  
      element.onTouchStart.listen((e) => _touchDown(e));
      element.onTouchMove.listen((e) => _touchDrag(e));
      element.onTouchEnd.listen((e) => _touchUp(e));
        
      // Prevent screen from dragging on ipad
      document.onTouchMove.listen((e) => e.preventDefault());
  }

  
/*
 * Convert mouseUp to touchUp events
 */
  void _mouseUp(MouseEvent evt) {
    TouchBinding target = touch_bindings[-1];
    if (target != null) {
      Contact c = new Contact.fromMouse(evt);
      target.touchUp(c);
    }
    touch_bindings[-1] = null;
    mdown = false;
  }
  
   
/*
 * Convert mouseDown to touchDown events
 */
  void _mouseDown(MouseEvent evt) {
    Contact t = new Contact.fromMouse(evt);
    TouchBinding target = findTouchTarget(t);
    if (target != null) {
      if (target.touchDown(t)) {
        touch_bindings[-1] = target;
      }
    }
    mdown = true;
  }
   
   
/*
 * Convert mouseMove to touchDrag events
 */
  void _mouseMove(MouseEvent evt) {
    if (mdown) {
      Contact t = new Contact.fromMouse(evt);
      TouchBinding target = touch_bindings[-1];
      if (target != null) {
        target.touchDrag(t);
      } else {
        target = findTouchTarget(t);
        if (target != null) {
          target.touchSlide(t);
        }
      }
    }
  }
   
   
  void _touchDown(TouchEvent evt) {
    Contact t = new Contact.fromTouch(evt);
    TouchBinding target = findTouchTarget(t);

    if (target != null) {
      if (target.touchDown(t)) {
        touch_bindings[t.id] = target;
      }
    }
    mdown = true;
  }
   
   
  void _touchUp(TouchEvent evt) {
    Contact t = new Contact.fromTouch(evt);
    TouchBinding target = touch_bindings[t.id];
    if (target != null) {
      target.touchUp(t);
      touch_bindings[t.id] = null;
    }
    bool touchExists = false;
    for (int i=0;i<touch_bindings.length;i++) {
      if (touch_bindings[i] != null) touchExists = true;
    }
    if (touchExists == false) touch_bindings.clear;

  }
   
   
  void _touchDrag(TouchEvent evt) {
    Contact t = new Contact.fromTouch(evt);
    TouchBinding target = touch_bindings[t.id];
    
    if (target != null) {
      target.touchDrag(t);
    } else {
      target = findTouchTarget(t);
      if (target != null) {
        target.touchSlide(t);
      }
    }
  }
  
  /* toggle commands for enable listening*/
  void enable(){
    for (int i=layers.length - 1; i >= 0; i--) {
      layers[i].enable();
    }
  }
  
  void disable(){
    for (int i=layers.length - 1; i >= 0; i--) {
      layers[i].disable();
    }
  }
  
}


class TouchLayer {

  /* A list of touchable objects on this layer */
  List<Touchable> touchables = new List<Touchable>();
   
  Map<int, Touchable> touch_bindings = new Map<int, Touchable>();
  bool enabled; 
  TouchLayer(){
    enabled = true;
  }
   

/*
 * Add a touchable object to the list
 */
  void addTouchable(Touchable t) {
    touchables.add(t);
  }
   

/*
 * Remove a touchable object from the master list
 */
  void removeTouchable(Touchable t) {
    touchables.remove(t);
  }
   
   
/*
 * Find a touchable object that intersects with the given touch event
 */
  Touchable findTouchTarget(Contact tp) { 
      Contact c = new Contact.copy(tp);
      if(enabled){
        for (int i=touchables.length - 1; i >= 0; i--) {
          if (touchables[i].containsTouch(c)) {
            return touchables[i];
          }
        }
      }
      return null;
  }
  
  void enable(){
    enabled = true;
  }
  
  void disable(){
    enabled = false;
  }
}


/*
 * Internal object used to keep track of mappings from touch ID numbers to
 * touchable objects.
 */
class TouchBinding {
  
  TouchLayer layer;
  Touchable touchable;
  
  TouchBinding(this.layer, this.touchable);
  
  
  bool touchDown(Contact c) {
    return touchable.touchDown(c);
  }
  
  void touchUp(Contact c) {
    touchable.touchUp(c);
  }
  
  void touchDrag(Contact c) {
    touchable.touchDrag(c);
  }
  
  void touchSlide(Contact c) {
    touchable.touchSlide(c);
  }
}


/*
 * Objects on the screen must implement this interface to receive touch events
 */
abstract class Touchable {
  
  bool containsTouch(Contact event);
   
  // This gets fired if a touch down lands on the touchable object. 
  // Return true to 'own' the touch event for the duration 
  // Return false to ignore the event (e.g. if disabled or if you want slide events)
  bool touchDown(Contact event);
   
  void touchUp(Contact event);
   
  // This gets fired only after a touchDown lands on the touchable object
  void touchDrag(Contact event);
   
  // This gets fired when an unbound touch events slides over an object
  void touchSlide(Contact event);
}


class Contact {
  int id;
  int tagId = -1;
  num touchX = 0;
  num touchY = 0;
  bool tag = false;
  bool up = false;
  bool down = false;
  bool drag = false;
  bool finger = false;
  
  Contact(this.id);
  
  Contact.fromMouse(MouseEvent mouse) {
    id = -1;
    touchX = mouse.offset.x.toDouble();
    touchY = mouse.offset.y.toDouble();
    finger = true;
  }

  
  Contact.fromTouch(TouchEvent touch) {
    touch.touches.forEach((touch) {
      var _id = touch.identifier;
      touchX = touch.page.x.toDouble();
      touchY = touch.page.y.toDouble();
      finger = true;
    });
  }
  
  
  Contact.copy(Contact c) {
    id = c.id;
    tagId = c.tagId;
    touchX = c.touchX;
    touchY = c.touchY;
    up = c.up;
    down = c.down;
    drag = c.drag;
    finger = c.finger;
  }
}
