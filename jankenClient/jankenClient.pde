import processing.net.*;

enum Result {
  WIN,
  DRAW,
  LOOSE
}

enum Hand {
  G(0),
  C(1),
  P(2);

  private int id;

  private Hand(final int id) {
    this.id = id;
  }

  static Hand valueOf(int id) {
    if (id == 0) {
      return Hand.G;
    } else if (id == 1) {
      return Hand.C;
    } else {
      return Hand.P;
    }
  }

  int getId() {
    return this.id;
  }

  String toString() {
    if (this.id == 0) {
      return "G";
    } else if (this.id == 1) {
      return "C";
    } else {
      return "P";
    }
  }

  Result battle(Hand hand) {
    if (this == Hand.G) {
      if (hand == Hand.G) {
        return Result.DRAW;
      } else if (hand == Hand.C) {
        return Result.WIN;
      } else {
        return Result.LOOSE;
      }
    } else if (this == Hand.C) {
      if (hand == Hand.G) {
        return Result.LOOSE;
      } else if (hand == Hand.C) {
        return Result.DRAW;
      } else {
        return Result.WIN;
      }
    } else {
      if (hand == Hand.G) {
        return Result.WIN;
      } else if (hand == Hand.C) {
        return Result.LOOSE;
      } else {
        return Result.DRAW;
      }
    }
  }
}

enum Status {
  INPUT,
  WAIT,
  RESULT
}

class Button {
  Hand hand;
  int cx, cy, size;
  color fillColor;
  boolean selected = false;

  Button(Hand hand, int cx, int cy, int size, color fillColor) {
    this.hand = hand;
    this.cx = cx;
    this.cy = cy;
    this.size = size;
    this.fillColor = fillColor;
  }

  boolean clicked() {
    return dist(mouseX, mouseY, cx, cy) <= size / 2;
  }

  void draw() {
    noStroke();
    if (this.selected) {
      fill(this.fillColor);
    } else {
      fill(this.fillColor, 100);
    }
    ellipse(this.cx, this.cy, this.size, this.size);
    fill(0);
    textAlign(CENTER, CENTER);
    text(this.hand.toString(), this.cx, this.cy);
  }
}

Client client;
Status currentStatus = Status.INPUT;
Button[] buttons;
Hand enemy = null;

void setup() {
  size(400, 400);

  client = new Client(this, "127.0.0.1", 5204);

  int size = 100;
  buttons = new Button[3];
  buttons[0] = new Button(Hand.G, size / 2, height / 2, size, color(255, 0, 0));
  buttons[1] = new Button(Hand.C, width / 2, height / 2, size, color(0, 255, 0));
  buttons[2] = new Button(Hand.P, width - size / 2, height / 2, size, color(0, 0, 255));
}

void draw() {
  background(255);
  Hand hand = null;
  for (Button button : buttons) {
    button.draw();
    if (button.selected) {
      hand = button.hand;
    }
  }
  if (currentStatus == Status.RESULT && hand != null) {
    fill(0);
    textAlign(CENTER, CENTER);
    text("enemy : " + enemy.toString(), width / 2, 60);
    Result result = hand.battle(enemy);
    if (result == Result.WIN) {
      text("win", width / 2, 100);
    } else if (result == Result.DRAW) {
      text("draw", width / 2, 100);
    } else {
      text("lose", width / 2, 100);
    }
  }
}

void mouseClicked() {
  if (currentStatus == Status.INPUT) {
    int selected = -1;
    for (Button button : buttons) {
      if (button.clicked()) {
        selected = button.hand.getId();
        button.selected = true;
      }
    }
    if (selected != -1) {
      client.write(selected);
      currentStatus = Status.WAIT;
    }
  } else if (currentStatus == Status.RESULT) {
    for (Button button : buttons) {
      button.selected = false;
    }
    enemy = null;
    currentStatus = Status.INPUT;
  }
}

void clientEvent(Client client) {
  enemy = Hand.valueOf(client.read());
  currentStatus = Status.RESULT;
}
