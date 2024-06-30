import processing.net.*;

Server server;

void setup() {
  server = new Server(this, 5204);
}

void draw() {
}

void clientEvent(Client client) {
  client.read();
  server.write(int(random(3)));
}
