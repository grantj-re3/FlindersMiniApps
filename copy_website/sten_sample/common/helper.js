/*
 * helper.js
 */

/*
 * POST to a target URL using an a-tag.  Invocation examples:
 *   <a onclick="post('myscript.php', {field1: 'value1'})" href="#" target="_top">VALUE1</a>
 *   <a onclick="post('http://example.com/mypage.html', {})" href="#" target="_top">VALUE1</a>
 *
 * Ref: http://stackoverflow.com/questions/133925/javascript-post-request-like-a-form-submit
 */
function post(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        if(params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);

            form.appendChild(hiddenField);
         }
    }

    document.body.appendChild(form);
    form.submit();
}

