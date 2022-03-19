(function () {
    $(function () {
        var basicAuthUI =
            '<div class="input"><input placeholder="username" id="input_username" name="username" type="text" size="10"></div>' +
            '<div class="input"><input placeholder="password" id="input_password" name="password" type="text" size="10"></div>';
        $(basicAuthUI).insertBefore("#api_selector div.input:last-child");
        $("#input_username").change(addBasicAuthorization);
        $("#input_password").change(addBasicAuthorization);
        $("#input_apiKey").hide();
    });

    function addBasicAuthorization() {
        var username = $("#input_username").val();
        var password = $("#input_password").val();

        if (username.trim() != "" & password.trim() != "") {
            var basicAuth = new window.SwaggerClient.PasswordAuthorization('basic', username, password);
            window.swaggerUi.api.clientAuthorizations.add("basicAuth", basicAuth);
            //console.log("authorization added: username = " + username + ", password = " + password);
        }
    }
})();