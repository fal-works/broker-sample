/**
 * Set this to any value for scaling the output result.
 */
const scaleFactor = 1.0;

/**
 * Just for animation preview.
 */
const animationIntervalFrameCount = 8;

/**
 * Just for preview. Not applied when saving the result.
 */
const backgroundLightness = 0.0;

const enemy = {
  frameSize: 72,
  frames: 4,
  name: "enemy",
  initGraphics: (gr) => {
    gr.stroke(255);
    gr.noFill();
    gr.rectMode(CENTER);

    // const context = gr.drawingContext;
    // context.shadowOffsetX = scaleFactor * 10;
    // context.shadowOffsetY = scaleFactor * 10;
    // context.shadowBlur = scaleFactor * 10;
    // context.shadowColor = `rgba(255, 255, 255, 1)`;
  },
  createDrawFrame: () => {
    return (gr, frameIndex) => {
      switch (frameIndex) {
        case 0: gr.strokeWeight(3); break;
        case 1: gr.strokeWeight(4); break;
        case 2: gr.strokeWeight(5); break;
        case 3: gr.strokeWeight(4); break;
      }

      gr.square(-16, -16, 20, 20);
      gr.square(+16, -16, 20, 20);
      gr.square(-16, +16, 20, 20);
      gr.square(+16, +16, 20, 20);
    };
  }
};

const enemyBullet = {
  frameSize: 24,
  frames: 4,
  name: "enemy_bullet",
  initGraphics: (gr) => {
    gr.stroke(255);
    gr.noFill();
    gr.rectMode(CENTER);
  },
  createDrawFrame: () => {
    return (gr, frameIndex) => {
      switch (frameIndex) {
        case 0: gr.strokeWeight(3); break;
        case 1: gr.strokeWeight(4); break;
        case 2: gr.strokeWeight(5); break;
        case 3: gr.strokeWeight(4); break;
      }

      gr.square(0, 0, 16, 16);
    };
  }
};

/**
 * The input data for creating the image.
 * Set this to any instance to switch the result.
 */
const data = enemyBullet;

/**
 * p5.Graphics instance for the result image.
 */
let gr;

function setup() {
  const { frameSize, frames, initGraphics, createDrawFrame } = data;
  const scaledFrameSize = Math.ceil(scaleFactor * frameSize);

  createCanvas(scaledFrameSize, scaledFrameSize);

  gr = createGraphics(scaledFrameSize, frames * scaledFrameSize);
  gr.scale(scaleFactor);
  initGraphics(gr);

  drawFrames(gr, frameSize, frames, createDrawFrame());
}

function drawFrames(gr, frameSize, frames, drawFrame) {
  const halfFrameSize = frameSize / 2;
  for (let i = 0; i < frames; i += 1) {
    gr.push();
    gr.translate(halfFrameSize, halfFrameSize + i * frameSize);
    drawFrame(gr, i);
    gr.pop();
  }
}

function draw() {
  background(backgroundLightness * 255);

  const frameIndex = Math.floor(frameCount / animationIntervalFrameCount) % data.frames;

  const srcX = 0;
  const srcY = frameIndex * width;
  copy(gr, srcX, srcY, width, height, 0, 0, width, height);
}

function keyTyped() {
  if (key == "s") save(gr, `${data.name}_${data.frameSize}px.png`);
  if (key == "p") noLoop();
  if (key == "r") loop();
}
