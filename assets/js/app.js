
document.addEventListener('DOMContentLoaded', function() {
  var up = document.getElementById("up");
  var down = document.getElementById("down");

  var state = {
    up: {
      width: up.clientWidth,
      height: up.clientHeight
    },
    down: {
      width: down.clientWidth,
      height: down.clientHeight
    }
  };

  function resized(el, key) {
    if(el.clientWidth != state[key].width || el.clientHeight != state[key].height){
      el.style.fontSize = `${el.clientWidth / 5}px`;
      console.log('resized');
    }
    state[key].width = el.clientWidth;
    state[key].height = el.clientHeight;
  }

  up.addEventListener("mouseup", function() {
    resized(up, 'up')
  });

  down.addEventListener("mouseup", function() {
    resized(down, 'down')
  });

  const d = document.getElementsByClassName("draggable");

  for (let i = 0; i < d.length; i++) {
    d[i].style.position = "relative";
  }

  function filter(e) {
    let target = e.target;

    if (!target.classList.contains("draggable")) { return; }

    target.moving = true;

    e.clientX ? // Check if Mouse events exist on user' device
    (target.oldX = e.clientX, // If they exist then use Mouse input
    target.oldY = e.clientY) :
    (target.oldX = e.touches[0].clientX, // otherwise use touch input
    target.oldY = e.touches[0].clientY)

    target.oldLeft = window.getComputedStyle(target).getPropertyValue('left').split('px')[0] * 1;
    target.oldTop = window.getComputedStyle(target).getPropertyValue('top').split('px')[0] * 1;

    document.onmousemove = dr;
    document.ontouchmove = dr;

    function dr(event) {
      event.preventDefault();

      if (!target.moving) { return; }

      event.clientX ?
      (target.distX = event.clientX - target.oldX,
      target.distY = event.clientY - target.oldY) :
      (target.distX = event.touches[0].clientX - target.oldX,
      target.distY = event.touches[0].clientY - target.oldY)

      target.style.left = target.oldLeft + target.distX + "px";
      target.style.top = target.oldTop + target.distY + "px";
    }

    function endDrag() {
      target.moving = false;
    }

    target.onmouseup = endDrag;
    target.ontouchend = endDrag;
  }

  document.onmousedown = filter;
  document.ontouchstart = filter;
})

