function switch_to_form(type, id) {
  $('#' + type + '_display_' + id).hide();
  $('#' + type + '_edit_form_' + id).show();
}

function switch_back_from_form(type, id) {
  $('#' + type + '_display_' + id).show();
  $('#' + type + '_edit_form_' + id).hide();
}
