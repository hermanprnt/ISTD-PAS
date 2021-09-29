$.progressShow = function (title, text) {
    if ($("body #progress-spinner").length === 0) {
        $("body").append("<div id=\"progress-spinner\" class=\"modal fade bs-example-modal-lg\" data-backdrop=\"static\" data-keyboard=\"false\">" +
            "<div class=\"modal-dialog modal-lg\" style=\"width:300px\">" +
            "<div class=\"modal-content\"><div class=\"modal-header\"><div id=\"progress-title\"></div></div>" +
            "<div class=\"modal-body\"><div class=\"text-center\"><p id=\"progress-text\"></p>" +
            "<img style=\"margin-top:25px;\" width=\"30\" height=\"30\" src=\"/Content/img/LoadingImage.gif\" />" +
            "</div></div></div></div></div>");
    }
    $("#progress-title").html(title);
    $("#progress-text").html(text);
    $("#progress-spinner").modal();
}

$.progressHide = function () {
    $("#progress-spinner").modal("hide");
}

function GetValidDate(date) {
    if (date != "") {
        date = date.split('.');
        var date = date[1] + '-' + date[0] + '-' + date[2];
    }
    return date;
}

function getChecked(data) {
    var result = [];

    $("input[id^=cb-]").each(function (i, a) {
        if (a.id != null && a.id.length > 0 && a.checked) {
            result.push($('#' + a.id).data(data));
        }
    });

    return result.join();
}

function CommonDatePickerOnChange(changedControl) {
    setTimeout(function () {
        var buttonPane = $(changedControl).datepicker("widget").find(".ui-datepicker-buttonpane");
        $(".ui-datepicker-current").css("display", "none");
        $(".ui-datepicker-close").css("display", "none");
        $(".ui-datepicker-month").css("font-color", "black");
        $("<button>", {
            text: "Clear",
            click: function () {
                //Code to clear your date field (text box, read only field etc.) I had to remove the line below and add custom code here
                $.datepicker._clearDate(changedControl);
            }
        }).appendTo(buttonPane).addClass("ui-datepicker-clear ui-state-default ui-priority-primary ui-corner-all");
    }, 1);
}

function ToDatePicker(leftRangeControl, rightRangeControl) {
    $(leftRangeControl).datepicker({
        dateFormat: 'dd.mm.yy',
        defaultDate: "+1w",
        onClose: function (selectedDate) {
            $(rightRangeControl).datepicker("option", "minDate", selectedDate);
        },
        showButtonPanel: true,
        beforeShow: function (input) {
            CommonDatePickerOnChange(input);
        },
        onChangeMonthYear: function (year, month, instance) {
            CommonDatePickerOnChange(instance);
        }
    });

    $(rightRangeControl).datepicker({
        dateFormat: 'dd.mm.yy',
        defaultDate: "+1w",
        onClose: function (selectedDate) {
            $(leftRangeControl).datepicker("option", "maxDate", selectedDate);
        },
        showButtonPanel: true,
        beforeShow: function (input) {
            CommonDatePickerOnChange(input);
        },
        onChangeMonthYear: function (year, month, instance) {
            CommonDatePickerOnChange(instance);
        }
    });
}

function ToSingleDatePicker(dateControl) {
    $(dateControl).datepicker({
        dateFormat: 'dd.mm.yy',
        defaultDate: "+1w",
        showButtonPanel: true,
        beforeShow: function (input) {
            CommonDatePickerOnChange(input);
        },
        onChangeMonthYear: function (year, month, instance) {
            CommonDatePickerOnChange(instance);
        }
    });
}

function ToYearOnlyDatePicker(dateControl) {
    $(dateControl).datepicker({
        changeMonth: false,
        changeYear: true,
        showButtonPanel: true,
        dateFormat: 'yy',

        onClose: function (dateText, inst) {
            var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
            $(this).datepicker('setDate', new Date(year, 1));
        },

        onChangeMonthYear: function(year, instance) {
             var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
            $(this).datepicker('setDate', new Date(year, 1));
        }
    });
}

$(document).on("click", "[data-hide]", function (e) {
    $(this).closest("." + $(this).attr("data-hide")).addClass("hidden");
});

// NOTE: difference between this and below is, this is get DisplayMessage from DB
function ShowDisplayMessage(messageContainer, messageId, messageType) {
    $.ajax({
        type: "POST",
        url: "/Message/GetDisplayMessage",
        data: {
            messageId: messageId
        },
        success: function (data) {
            messageType = messageType || messageId.substring(0, 3);
            $(messageContainer).removeClass("alert-success alert-warning alert-danger alert-info hidden");
            //$(messageContainer).addClass("alert-dismissable");
            switch (messageType) {
                case "WRN":
                case "W":
                    $(messageContainer).addClass("alert-warning");
                    break;
                case "ERR":
                case "E":
                    $(messageContainer).addClass("alert-danger");
                    break;
                default:
                    $(messageContainer).addClass("alert-info");
                    break;
            }

            $(messageContainer).html(
                "<button type=\"button\" class=\"close\" data-hide=\"alert\" aria-label=\"Close\">" +
                "<span aria-hidden=\"true\">&times;</span></button>" +
                "<strong>" + data + "</strong>");
        },
        error: function (data) {
            $(messageContainer).addClass("hidden");
            console.log(data.responseText);
        }
    });
}

function ShowMessage(messageContainer, messageContent, messageType) {
    messageType = messageType || "INF";
    $(messageContainer).removeClass("alert-success alert-warning alert-danger alert-info hidden");
    //$(messageContainer).addClass("alert-dismissable");
    switch (messageType) {
        case "WRN":
        case "W":
            $(messageContainer).addClass("alert-warning");
            break;
        case "ERR":
        case "E":
            $(messageContainer).addClass("alert-danger");
            break;
        default:
            $(messageContainer).addClass("alert-info");
            break;
    }

    $(messageContainer).html(
        "<button type=\"button\" class=\"close\" data-hide=\"alert\" aria-label=\"Close\">" +
        "<span aria-hidden=\"true\">&times;</span></button>" +
        "<strong>" + messageContent + "</strong>");
}

function StringFormat(message, param) {
    if (Object.prototype.toString.apply(param) !== "[object Array]") {
        throw Error("param is not array.");
    }

    for (var i = 0; i < param.length; i++) {
        message = message.replace("{" + i + "}", param[i].toString());
    }

    return message;
}