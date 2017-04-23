import processing.pdf.*;

int MAX_RAD = 30;
int TOTAL_SPRAY_NUM = 1000;
int SPRAY_PER_FRAME = 100;
int POINT_IN_A_SPRAY_NUM = 100;
boolean LOGARITHMIC_SPLAY = false;

PGraphics canvas;
Svg template;
color[] colors = {color(255,0,0),color(0,255,0),color(0,0,255)};
int totalSprayNum = 0;

void setup() {
  template = new Svg("knowtest.svg");
  
  size(template.width, template.height);
  
  canvas = createGraphics(width, height/*, P2D, "./out.png"*/);
  background(255,0);
  noStroke();
  smooth();
}
 
void draw() {
  canvas.beginDraw();
  float angle,radius;
  int offsetX, offsetY;
  
  for(int p=0;p<SPRAY_PER_FRAME && totalSprayNum<TOTAL_SPRAY_NUM;p++,totalSprayNum++)
  {
  
    while(true){
      offsetX = int(random(0, width));
      offsetY = int(random(0, height));
      if(template.contain(new PVector(offsetX,offsetY))) break;
    }
      
    for(int i=0;i<POINT_IN_A_SPRAY_NUM;i++){
      color pointColor = colors[i % 3];
      if(LOGARITHMIC_SPLAY){
        radius = -log(random(0,1))*MAX_RAD;
      }
      else{
        radius = randomGaussian()*MAX_RAD;
      }
      angle = random(0,TWO_PI);
      
      canvas.set(int(offsetX+cos(angle)*radius),  int(offsetY+sin(angle)*radius), pointColor);
      
    //    canvas.fill(pointColor);
    //    canvas.noStroke();
    //    canvas.smooth();
    //    canvas.arc(offsetX+cos(angle)*radius,  offsetY+sin(angle)*radius, 3, 3, 0, TWO_PI);
  
    }
  }
  canvas.endDraw();
  shape(template.svg,0,0);
  image(canvas,0,0);
  //noloop();
  saveFrame("out-###.tif");
}

void mousePressed() {
  //canvas.clear();
  
}

class Svg {
  private PShape svg;
  public int width;
  public int height;
  
  public Svg (String svgFile){
    this.svg = loadShape(svgFile);
    this.width = int(this.svg.width);
    this.height = int(this.svg.height);
  }
  
  boolean contain(PVector point) {
    int childCount  = this.svg.getChildCount();
    float[] interceptXs = {}; 

    for(int childIndex = 0;childIndex<childCount;childIndex++){
      PShape svgChild = this.svg.getChild(childIndex);
      int vertexCount = svgChild.getVertexCount();
      for(int i=1;i<vertexCount; i++){

        PVector v0  = new PVector(svgChild.getVertexX(i-1), svgChild.getVertexY(i-1));
        PVector v1  = new PVector(svgChild.getVertexX(i), svgChild.getVertexY(i));
        if(v0.y < point.y && point.y <= v1.y || v1.y < point.y && point.y <= v0.y){
          interceptXs = append(interceptXs, v0.x + (point.y-v0.y)*(v1.x-v0.x)/(v1.y-v0.y));
        }
      }
    }
    interceptXs = sort(interceptXs);

    for(int i=1;i<interceptXs.length;i+=2){
      if(interceptXs[i-1] < point.x && point.x <= interceptXs[i]){
        return true;
      }
    }
    return false;
  }
  
  void scanLine(){}
}
