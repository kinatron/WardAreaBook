function switch_to_comment_form(comment_id) {
  $('#comment_' + comment_id).hide();
  $('#comment_edit_form_' + comment_id).show();
}

function switch_back_from_comment_from(comment_id) {
  $('#comment_' + comment_id).show();
  $('#comment_edit_form_' + comment_id).hide();
}
