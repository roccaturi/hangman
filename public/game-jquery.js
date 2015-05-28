$(document).ready(function() {
  var progress = gon.missed_appeals
  switch(true) {
    case progress == 1:
      $("#stick_head").css("display", "block")
      break;
    case progress == 2:
      $("#stick_head").css("display", "block")
      $("#stick_body").css("display", "inline-block")
      break;
    case progress == 3:
      $("#stick_head").css("display", "block")
      $("#stick_body").css("display", "inline-block")
      $("#stick_left_arm").css("display", "inline-block")
      $("#stick_right_arm").css("display", "inline-block")
      break;
    case progress == 4:
      $("#stick_head").css("display", "block")
      $("#stick_body").css("display", "inline-block")
      $("#stick_left_arm").css("display", "inline-block")
      $("#stick_right_arm").css("display", "inline-block")
      $("#stick_left_leg").css("display", "inline-block")
      $("#stick_right_leg").css("display", "inline-block")
      break;
    case progress == 5:
      $("#stick_head").css("display", "block")
      $("#stick_body").css("display", "inline-block")
      $("#stick_left_arm").css("display", "inline-block")
      $("#stick_right_arm").css("display", "inline-block")
      $("#stick_left_leg").css("display", "inline-block")
      $("#stick_right_leg").css("display", "inline-block")
      $('#gallows_rope').css("display", "inline-block")
      $('#gallows_noose').css("display", "inline-block")
      $('#game_appeals').css("display", "none")
      $('#game_execution').css("display", "inline-block")
      break;
    case progress >= 6:
      $('#gallows_rope_extended').css("display", "inline-block")
      $('#game_appeals').css("display", "none")
      $('#game_postmortem').css("display", "inline-block")
      break;
  }
});
