!function ($) {
    "use strict";

    $.messagebox = {
        show: function (title, text, type, msgboxbutton, trueevent, falseevent) {
            var confirmId = "";
            if (msgboxbutton == "CONFIRM")
                confirmId = msgboxbutton;
            if ($("body #messagebox" + confirmId).length === 0) {
                $("body").append("<div id=\"messagebox" + confirmId + "\" class=\"modal fade bs-example-modal-lg\" data-backdrop=\"static\" data-keyboard=\"false\">" +
                    "<div class=\"modal-dialog\" style=\"min-width:300px\">" +
                    "<div class=\"modal-content\"><div class=\"modal-header\"><div class=\"close\" style=\"opacity:1 !important;margin-top:-7px;\">" +
                    "<span aria-hidden=\"true\" id=\"message-img\"></span></div><div id=\"messagebox-title\"></div></div>" +
                    "<div class=\"modal-body\"><div class=\"text-left\" style=\"overflow-y: auto; max-height: 515px;\"><p id=\"messagebox-text\"></p>" +
                    "</div><div id=\"message-button\"></div></div></div></div></div>");
            }

            $('#messagebox'+ confirmId+' .modal-backdrop').not(':eq(0)').not(':eq(1)').remove();

            var modalContent = $("body #messagebox" + confirmId + " .modal-content");
            var confirmButton = "<div class=\"row\" style=\"text-align: right;padding-right: 10px; margin-top: 10px;\">" +
                              "<button type=\"button\" class=\"btn btn-primary btn-std btn-xs\" data-dismiss=\"modal\" onclick=\"" +
                              (trueevent !== "" ? "javascript:" + trueevent : "") +
                              "\">Yes</button>" +
                              "<button class=\"btn btn-danger btn-xs btn-std\" data-dismiss=\"modal\"  onclick=\"" +
                              (falseevent !== "" ? "javascript:" + falseevent : "") +
                              "\">No</button>" +
                              "</div>";

            var singleButton = "<div class=\"row\" style=\"text-align: right;padding-right: 10px; margin-top: 10px;\">" +
                              "<button type=\"button\" class=\"btn btn-primary btn-xs btn-std\" data-dismiss=\"modal\" onclick=\"" +
                              (trueevent !== "" ? "javascript:" + trueevent : "") +
                              "\">OK</button>" +
                              "</div>";
            var img = "";
            modalContent.removeClass("message-info message-warning message-danger message-success");
            type = type || "INF";
            switch (type) {
                case "W":
                case "WRN":
                    img = "<img src=\"/Content/Bootstrap/img/Warning.png\" class=\"modal-icon\" />";
                    modalContent.addClass("message-warning");
                    break;
                case "E":
                case "ERR":
                    img = "<img src=\"/Content/Bootstrap/img/Error.png\" class=\"modal-icon\" />";
                    modalContent.addClass("message-danger");
                    break;
                case "S":
                case "SUC":
                    img = "<img src=\"/Content/Bootstrap/img/information.png\" class=\"modal-icon\" />";
                    modalContent.addClass("message-success");
                    break;
                default:
                    img = "<img src=\"/Content/Bootstrap/img/information.png\" class=\"modal-icon\" />";
                    modalContent.addClass("message-info");
                    break;
            }

            switch (msgboxbutton) {
                case "CONFIRM":
                    img = "<img src=\"/Content/Bootstrap/img/question.png\" class=\"modal-icon\" />";
                    $("#messagebox" + confirmId + " #message-button").html(confirmButton);
                    break;
                case "SINGLE":
                default:
                    $("#messagebox" + confirmId + " #message-button").html(singleButton);
                    break;
            }

            switch (title) {
                case "W":
                case "WRN":
                    title = "Warning";
                    break;
                case "E":
                case "ERR":
                    title = "Error";
                    break;
                case "S":
                case "SUC":
                    title = "Success";
                    break;
                case "I":
                case "INF":
                    title = "Information";
                    break;
            }

            $("#messagebox"+ confirmId+ " #message-img").html(img);
            $("#messagebox" + confirmId + " #messagebox-title").html(title);
            $("#messagebox" + confirmId + " #messagebox-text").html(text);

            $("#messagebox"+ confirmId).modal();
        },

        hide: function () {
            $("#messagebox"+ confirmId).modal("hide");
        }
    }

}(window.jQuery);