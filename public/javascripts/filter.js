function filterTable(phrase, _id, nameCell, statusCell){
  var words = phrase.value.toLowerCase().split(" ");
  var table = document.getElementById(_id);
  var nameCellContents;
  var statusCellContents;
  for (var r = 1; r < table.rows.length; r++){
    nameCellContents   = table.rows[r].cells[nameCell].innerHTML.replace(/<[^>]+>/g,"");
    statusCellContents = table.rows[r].cells[statusCell].innerHTML.replace(/<[^>]+>/g,"");
    for (var i = 0; i < words.length; i++) {
      if (nameCellContents.toLowerCase().indexOf(words[i])>=0 || statusCellContents.toLowerCase().indexOf(words[i])>=0)
        displayStyle = '';
      else { 
        displayStyle = 'none';
        break;
      }
    }
    table.rows[r].style.display = displayStyle
  }
}
