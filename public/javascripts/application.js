function display_no_match_found() {
  $('#response').html('<span class="no-match">No match found.</span>')
}

/*
 * Bind to the keyup event for the text fields. Set a timeout before
 * performing the ajax call so we're not sending lots of requests on keyup.
 */
regex_timeout = null
$('#regex-options, #data, #regex, #replace-data').keyup(function() {
  if(regex_timeout) {
    clearTimeout(regex_timeout)
  }
  regex_timeout = setTimeout(test_regex, '500')
})

$('##regex-options-python input').change(function() {
  $('#data').keyup()
})

$('#method').change(function() {
  if($(this).val() == 'replace') {
    $('#replace-input').slideDown()
  } else {
    $('#replace-input').slideUp()
  }

  // Trigger keyup, and thus triggering ajax call.
  $('#data').keyup()
})

$('#language').change(function() {
  $('#quick-ref').load('/quickref', 'language=' + $(this).val())

  var display = $('#regex-options-python').css('display')

  if($(this).val() == 'python' && display != 'block') {
    $('#regex-options-normal .slash').hide()
    $('#regex-options').fadeOut(function() {
      $('#regex').animate({'width': '968px'}, 500, function() {
        $('#regex-options-python').slideDown('fast')
      })
    })
  } else if($(this).val() != 'python' && display == 'block') {
    $('#regex-options-python').slideUp('fast', function() {
      $('#regex').animate({'width': '861px'}, 500, function() {
        $('#regex-options-normal .slash, #regex-options').fadeIn()
      })
    })
  }

  $('#data').keyup()
})

/*
 * Perform the ajax call for testing regular expressions.
 */
function test_regex() {
  // Handle the Javascript test natively.
  $.ajax({
    'url': $('#regex-form').attr('action'),
    'type': 'POST',
    'dataType': 'json',
    'data': $('#regex-form').serialize(),
    'success': handleResponse,
    'error': function(request, status, error) {
      display_no_match_found()
    }
  })
}

/*
 *
 */
function handleResponse(response) {
  if(response.matches && response.matches.length > 0) {
    var data = $('#data').val()
    var items = '<hr /><h3 class="group-header">Groups:</h3>'
    $.each(response.matches, function(index, item) {
      // TODO: Find a better replace method?
      var regex = new RegExp(item + '{1}')
      data = data.replace(regex, '<span class="highlight">' + item + '</span>')
      items += '[' + index + '] => ' + item + '<br />'
    })
    // Do we have any named groups?
    if(response.named_matches) {
      items += '<br /><h3 class="group-header">Named Groups:</h3>'
     $.each(response.named_matches, function(index, item) {
       items += '[' + index + '] => ' + item + '<br />'
     })
    }
    data += items
  } else if(response.replaced_data) {
    data = response.replaced_data
  } else {
    data = '<span class="no-match">No match found.</span>'
  }

  $('#response').html(data)
}