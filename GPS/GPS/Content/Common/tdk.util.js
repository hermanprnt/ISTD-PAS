(function ($) {
    "use strict";

    /* ==================== InvalidOperationException: begin ==================== */

    // NOTE: mimic InvalidOperationException of C#
    window.InvalidOperationException = function (message) {
        this.name = "InvalidOperationException";
        this.message = message || "";
        this.stack = (new Error()).stack;
        this.message = JSON.stringify(this);
    }
    InvalidOperationException.prototype = Object.create(Error.prototype);
    InvalidOperationException.prototype.constructor = InvalidOperationException;

    /* ===================== InvalidOperationException: end ===================== */

    /* ============================= GetType: begin ============================= */

    // NOTE: mimic typeof or GetType feature of c#
    window.GetType = function (obj) {
        return Object.prototype.toString.call(obj)
            .replace("[object ", "")
            .replace("]", "");
    };

    $.fn.GetType = function () {
        return $(this).map(function (idx, el) { return GetType(el); });
    };

    /* ============================== GetType: end ============================== */

    /* ======================== Other extensions: begin ======================== */

    // NOTE: Get value even the element is undefined
    $.fn.valOrDefault = function () {
        var $this =  $(this);
        var $thisval = $this.val();
        if ($thisval === undefined || $thisval === null || $thisval === "")
            return GetType($this[0]) === "HTMLInputElement"
                && $this.attr("type") === "number" ? "0" : "";

        return $thisval.trim();
    }

    // NOTE: Attach event only once
    $.fn.onOnce = function (a, b, c) {
        $(this)
            .off(a, b)
            .on(a, b, c);
    }

    // NOTE: This function may help when unexpected behavior occur
    // like jquery selector can't return any value
    window.CheckDuplicateId = function () {
        $("[id]").each(function() {
            var ids = $("[id='" + this.id + "']");
            if (ids.length > 1 && ids[0] === this)
                console.warn("Duplicate id #" + this.id);
        });
    };

    /* ========================= Other extensions: end ========================= */

    /* ======================== String extensions: begin ======================== */

    String.Cut = function (originalString, cutSize) {
        var cutString = [];
        var pieceIdx = 0;
        for (var counter = 0, sLen = originalString.length; counter < sLen; counter += cutSize) {
            var startIdx = (counter > sLen) ? sLen : counter;
            var length = cutSize > (sLen - counter) ? (sLen - counter) : cutSize;
            cutString.push(originalString.substring(startIdx, startIdx + length));
            pieceIdx++;
        }

        return cutString;
    }

    String.Reverse = function (originalString) {
        var reversed = [];
        for (var idx = originalString.length - 1; idx >= 0; idx--) {
            reversed.push(originalString[idx]);
        }

        return reversed.join("");
    }

    String.FormatDecimal = function (decimal) {
        var decimalString = Number(decimal) + ""; // NOTE: convert to number to trim trailing 0. + "" to convert to string

        var splitDecimal = decimalString.split(".");
        if (splitDecimal.length == 1)
            splitDecimal.push("00");
        var reversed = String.Cut(String.Reverse(splitDecimal[0]), 3);
        splitDecimal[0] = String.Reverse(reversed.join(","));

        return splitDecimal.join(".");
    }

    String.Format = function (originalString, param) {
        var paramType = GetType(param);
        var formatted = "";
        if (paramType !== "Array" || paramType !== "Object")
            throw new InvalidOperationException("params must be an Array or an Object.");

        switch (paramType) {
            case "Array":
                for (var i = 0; i < param.length; i++)
                    formatted = originalString.replace("{" + i + "}", param[i].toString());
                break;
            case "Object":
                for (var prop in param)
                    formatted = originalString.replace("{" + prop + "}", param[prop].toString());
                break;
        }

        return formatted;
    }

    /* ========================= String extensions: end ========================= */

    function DisableControl(idList, isDisabled) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of Disable must be an Array of selector.");

        idList.forEach(function (item) {
            var element = $(item);
            element.removeAttr("readonly").removeAttr("disabled");
            // NOTE: firefox has bug which never readonlied input with type="number" so just disable all except input type="text"
            // see this: https://support.mozilla.org/en-US/questions/1004206
            element.prop(GetType(element[0]) === "HTMLInputElement" && element.attr("type") === "text" ? "readonly" : "disabled", isDisabled);
        });
    }

    $.Disable = function (idList) { DisableControl(idList, true); };
    $.Enable = function (idList) { DisableControl(idList, false); };

    $.Clear = function (idList) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of Clear must be an Array of selector.");

        idList.forEach(function (item) {
            var element = $(item);
            var elementType = GetType(element[0]);
            switch (elementType) {
                case "HTMLInputElement":
                    if (element.attr("type") === "text")
                        element.val("");
                    else if (element.attr("type") === "number")
                        element.val(0);
                    break;
                case "HTMLSelectElement":
                    element.val(undefined);
                    break;
            }
        });
    };

    $.ValidateASPError = function (errorMessage) {
        var result = {
            IsASPError: false,
            Message: errorMessage
        };

        var tmp = $(document.createElement("div"));
        tmp.html(errorMessage);

        var comment = tmp.contents().filter(function () { return this.nodeType === 8; });
        if (comment.length > 0) {
            result.IsASPError = true;
            result.Message = comment.get(0).nodeValue;
        }

        return result;
    };

    // NOTE: mimic ViewData of razor which is Dictionary
    window.ViewData = (function () {
        var tmp = {};

        return {
            Get: function (key) {
                if (tmp.hasOwnProperty(key))
                    return tmp[key];
                return undefined;
            },
            Add: function (key, value) {
                tmp[key] = value;
            },
            Remove: function (key) {
                delete this.tmp[key];
            },
            Clear: function () {
                tmp = {};
            },
            GetKeys: function () {
                var keys = [];
                for (var key in tmp)
                    if (tmp.hasOwnProperty(key))
                        keys.push(key);
                return keys;
            }
        };
    })();

    $.NumericKey = function (e) {
        if ($.inArray(e.keyCode, [
                46, // Delete
                8, // Backspace
                9, // Tab
                27, // Esc
                13, // Enter
                110, // Numpad .
                190 // Numpad ,
            ]) !== -1 ||
            (e.keyCode === 65 && e.ctrlKey === true) || // Ctrl+A
            (e.keyCode >= 35 && e.keyCode <= 40)) {
            return;
        }
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    };

    $.NumericWithoutCommaKey = function (e) {
        if ($.inArray(e.keyCode, [
                46, // Delete
                8, // Backspace
                9, // Tab
                27, // Esc
                13, // Enter
                110 // Numpad .
            ]) !== -1 ||
            (e.keyCode === 65 && e.ctrlKey === true) || // Ctrl+A
            (e.keyCode >= 35 && e.keyCode <= 40)) {
            return;
        }
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    };

    $.AsPrice = function (number) {
        var str = number + "", parts = false, output = [], i = 1, formatted = null;
        if (str.indexOf(".") > 0) {
            parts = str.split(".");
            str = parts[0];
        }
        str = str.split("").reverse();
        for (var j = 0, len = str.length; j < len; j++) {
            if (str[j] != ",") {
                output.push(str[j]);
                if (i % 3 == 0 && j < (len - 1)) {
                    output.push(",");
                }
                i++;
            }
        }
        formatted = output.reverse().join("");
        return (formatted + ((parts) ? "." + parts[1].substr(0, 2) : ""));
    };

    $.FromPrice = function (numericString) {
        return Number(numericString.replace(/,/g, ""));
    };

    /*
    $.SumOf = function (idList) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of Clear must be an Array of selector.");

        var result = 0;
        idList.forEach(function (item) {
            result += $.FromPrice($(item).val());
        });

        return $.AsPrice(result);
    };

    $.TimesOf = function (idList) {
        if (GetType(idList) !== "Array")
            throw new InvalidOperationException("idList of Clear must be an Array of selector.");

        var result = 0;
        idList.forEach(function (item) {
            result *= $.FromPrice($(item).val());
        });

        return $.AsPrice(result);
    };
    */

    $(document).ready(function () {
        $(document).on("keydown", function (e) {
            if ((document.activeElement.getAttribute("type") !== "text" || document.activeElement.getAttribute("type") !== "number") &&
                (document.activeElement.readOnly || document.activeElement.disabled)) {
                if (e.keyCode === 8)
                    e.preventDefault();
            }
        });
    });

})(window.jQuery);