(function ($) {
    "use strict";

    // NOTE: it's very unconvenient method. but for now it works
    // for future dev, change this convension-based to data-based
    // Now: id="cmb-poitem-1" --> { DataName: "poitem", DataNo: 1 }
    // Future: id="cmbx" data-name="poitem" data-no="1" --> { DataName: "poitem", DataNo: 1 }
    $.fn.GetElementInfo = function () {
        var $this = $(this);
        var splittedId = $this.attr("id").split("-");
        return {
            DataName: splittedId[1],
            DataNo: splittedId[splittedId.length - 1]
        }
    };

    $.fn.GetPageSize = function () {
        var $thisval = Number($(this).valOrDefault());
        return $thisval === 0 ? 10 : $thisval;
    };

    /* =========================== Date Picker: begin =========================== */

    // NOTE: to apply common date picker control
    $.fn.todatepicker = function (isNoBackdate) {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "text")
            throw new InvalidOperationException("Must be an input with type=\"text\" element.");

        var options = {
            format: "dd.mm.yyyy",
            autoclose: true
        };
        if (isNoBackdate)
            options.startDate = "0d"

        $this.datepicker(options);
    };

    // NOTE: to get value from daterange picker control
    $.fn.parsedaterange = function () {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "text")
            throw new InvalidOperationException("Must be an input with type=\"text\" element.");

        var dateRange = ($this.valOrDefault() === "" ? " - " : $this.valOrDefault()).split(" - ");
        if (GetType(dateRange) !== "Array" ||
            dateRange.length !== 2)
            throw new InvalidOperationException("Can't parse date range because of invalid format.");

        return {
            From: dateRange[0],
            To: dateRange[1]
        }
    };

    // NOTE: to apply common daterange picker control
    $.fn.todaterangepicker = function (datefrom) {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "text")
            throw new InvalidOperationException("Must be an input with type=\"text\" element.");

        if (datefrom === '' || datefrom === null || datefrom === 'undefined')
            datefrom = new Date().getDate();

        $this.daterangepicker({
            format: "DD.MM.YYYY",
            applyClass: "btn-xs btn-primary btn-std",
            cancelClass: "btn-xs btn-danger btn-std",
            startDate: datefrom,
            locale: {
                applyLabel: "Apply",
                cancelLabel: "Cancel"
            }
        })
        .prev().on(ace.click_event, function () {
            $(this).next().focus();
        });
    };

    /* ============================ Date Picker: end ============================ */

    /* ========================= Display Message: begin ========================= */

    // NOTE: to get DisplayMessage from Db
    $.displaymessagebox = {
        show: function (displayMessageId, type) {
            $.ajax({
                type: "POST",
                url: "/DisplayMessage/GetDisplayMessage",
                async: false,
                data: {
                    messageId: displayMessageId
                },
                success: function (data) {
                    type = type || displayMessageId.substring(0, 3);
                    $.messagebox.show(type, data, type);
                },
                error: function (data) {
                    $.messagebox.hide();
                    console.log(data.responseText);
                }
            });
        }
    };

    /* ========================== Display Message: end ========================== */

    /* ============================ Checkbox: begin ============================ */

    // NOTE: to apply check all effect in checkbox
    $(document).on("change", "[id^=chkall-]", function (e) {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "checkbox")
            throw new InvalidOperationException("Must be an input with type=\"checkbox\" element.");

        var $dataname = $this.attr("id").split("-")[1];
        var $chks = $("[id^=chk-" + $dataname + "-]:not([disabled])");
        var isChecked = $this.prop("checked");
        $chks.each(function (idx, el) {
            $(this).prop("checked", isChecked);
        });
    });

    $(document).on("change", "[id^=chk-]", function (e) {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "checkbox")
            throw new InvalidOperationException("Must be an input with type=\"checkbox\" element.");

        var $dataname = $this.attr("id").split("-")[1];
        var $chkall = $("[id^=chkall-" + $dataname + "]");
        var isCheckedAll = $("[id^=chk-" + $dataname + "-]:checked:not([disabled])").length === $("[id^=chk-" + $dataname + "-]:not([disabled])").length;
        $chkall.prop("checked", isCheckedAll);
    });

    window.ResetCheckbox = function (dataName) {
        $("[id^=chk-" + dataName + "-]:checked:not([disabled])").each(function (e) {
            $(this).prop("checked", false);
        });
    }

    /* ============================= Checkbox: end ============================= */

    /* ============================= Toggle: begin ============================= */

    // NOTE: to show/hide detail in grid
    $.fn.toggledetail = function (onhide, onshow) {
        var $this = $(this);
        var $hiddencol = $($this.selector + " .col-hidden");
        var $datarow = $($this.selector + " table > tbody > tr > td");
        if ($hiddencol.hasClass("hidden")) {
            $hiddencol.removeClass("hidden");
            if (onshow)
                onshow($datarow);
        }
        else {
            $hiddencol.addClass("hidden");
            if (onhide)
                onhide($datarow);
        }
    };

    // NOTE: to show/hide sub item in grid
    $.fn.ToggleSubItem = function (onexpanding, onexpanded, oncollapsing, oncollapsed, embeddeddata) {
        var $this = $(this);
        var splittedId = $this.attr("id").split("-");
        var $thisElInfo = $this.GetElementInfo();
        var $dataname = $thisElInfo.DataName;
        var $dataNo = $thisElInfo.DataNo;
        var $row = $("#exprow-" + $dataname + "-" + $dataNo);
        if (!embeddeddata)
            embeddeddata = $this.data("embedded");

        if ($this.hasClass("fa-plus-square-o")) {
            $this.removeClass("fa-plus-square-o");
            $this.addClass("fa-minus-square-o");
            if (onexpanding)
                onexpanding($dataname, $dataNo, embeddeddata, $row, onexpanded);
        }
        else {
            $this.removeClass("fa-minus-square-o");
            $this.addClass("fa-plus-square-o");
            if (oncollapsing)
                oncollapsing($dataname, $dataNo, embeddeddata, $row, oncollapsed);
        }
    };

    /* ============================== Toggle: end ============================== */

    /* ============================ Validate: begin ============================ */

    function ConvertByteToMegaByte(size) {
        return Math.round((size / 1000000) * 100) / 100;
    }

    $.fn.validatefile = function (validationInfo) {
        var $this = $(this);
        if (GetType($this) !== "HTMLInputElement" && $this.attr("type") !== "file")
            throw new InvalidOperationException("Must be an input with type=\"file\" element.");
        if (GetType(validationInfo) !== "Object" && validationInfo.AllowedExtensions && validationInfo.AllowedFileSize)
            throw new InvalidOperationException("Must be an object with AllowedExtensions and AllowedFileSize properties.");

        var $uploadedfiles = $this[0].files;
        for (var idx = 0; idx < $uploadedfiles.length; idx++) {
            var $currentfile = $uploadedfiles[idx];
            var $splittedname = $currentfile.name.split(".");
            var $currentext = "." + $splittedname[$splittedname.length - 1];

            if ($.inArray($currentext, validationInfo.AllowedExtensions) === -1)
                throw new InvalidOperationException("File with type " + $currentext + " is not allowed. Allowed extensions are " + validationInfo.AllowedExtensions.join(", ") + ".");

            var $currentfilesize = ConvertByteToMegaByte($currentfile.size);
            var $allowedfilesize = ConvertByteToMegaByte(validationInfo.AllowedFileSize);
            if ($currentfilesize > $allowedfilesize)
                throw new InvalidOperationException("File " + $currentfile.name + " size (" + $currentfilesize + " MB) is reaching limit. Allowed filesize for " + $currentext + " is " + $allowedfilesize + ".");
        }
    };

    $.ValidateMandatory = function (idList, predicate) {
        if (predicate && GetType(predicate) !== "Function")
            throw new InvalidOperationException("predicate must be a function.");

        var mandatoryEmptyList = [];
        for (var i = 0; i < idList.length; i++) {
            var $this = $(idList[i]);
            var $thisElement = $this;
            var $thisValue = $this.valOrDefault();

            if ($this.hasClass("lookup")) {
                $thisElement = $this.find("[id^=txtlookup]");
                $thisValue = $thisElement.valOrDefault();
            }

            var isNotValid = predicate ? !predicate($thisValue) : $thisValue === "" || $thisValue === "0";
            if (isNotValid) {
                $thisElement.addClass("mandatory-empty");
                mandatoryEmptyList.push($thisElement);
            }
        }

        if (mandatoryEmptyList.length > 0) {
            var mandatoryTimer = setTimeout(function () {
                for (var i = 0; i < mandatoryEmptyList.length; i++)
                    $(mandatoryEmptyList[i]).removeClass("mandatory-empty");
                clearTimeout(mandatoryTimer);
            }, 10000);
        }
        return mandatoryEmptyList.length === 0;
    };

    /* ============================= Validate: end ============================= */

    /* ============================ DateInput: begin ============================ */

    function DIDisable (idList, isDisabled) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of DisableDateInput must be an Array of selector.");

        idList.forEach(function (item) {
            var $item = $(item);
            if ($item.hasClass("dateinput")) {
                if (isDisabled)
                    $item.find("input.dateinputbox").addClass("dateinput-disabled");
                else
                    $item.find("input.dateinputbox").removeClass("dateinput-disabled");
            }
        });
    }

    $.DisableDateInput = function (idList) { DIDisable(idList, true); }
    $.EnableDateInput = function (idList) { DIDisable(idList, false); }

    /* ============================= DateInput: end ============================= */

})(window.jQuery);