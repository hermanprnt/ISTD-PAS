!function ($) {
    "use strict";

    $.fn.lookupgrid = function () {
        var $lookupgrid = $(this);
        var $txtlookup = $lookupgrid.find("input[type=text][id^=txtlookup-]");
        var $btnlookup = $lookupgrid.find("button[id^=btnlookup-]");
        var $txtfilter = $lookupgrid.find("input[type=text][id^=txtfilter-]");
        var $btnclearfilter = $lookupgrid.find("button[id^=btnclearfilter-]");
        var $popuplookup = $lookupgrid.find(".popup-lookup-grid");
        var $chkall = $lookupgrid.find("input[type=checkbox][id^=chkall-]");
        var $datagrid = $lookupgrid.find("table[id^=datagrid-]");
        var $chks = $datagrid.find("input[type=checkbox][id^=chk-]");
        var $btnok = $lookupgrid.find("button[class*=btn-action][data-role=select-lookupgrid]");
        var $btncancel = $lookupgrid.find("button[class*=btn-action][data-role=dismiss-lookupgrid]");

        $(document).on("click", "#" + $btnlookup.attr("id"), function (e) {
            $txtfilter.val("");
            $chkall.prop("checked", false);
            $chks.prop("checked", false);
            if ($popuplookup.hasClass("open"))
                $popuplookup.removeClass("open");
            else
                $popuplookup.addClass("open");
        });

        $(document).on("click", $btnclearfilter.selector, function (e) {
            $txtfilter.val("");
        });

        $(document).on("change", "#" + $chkall.attr("id"), function (e) {
            var isChecked = $(this).prop("checked");
            $chks.each(function (idx, el) {
                $(this).prop("checked", isChecked);
            });
        });

        $(document).on("change", $chks.selector, function (e) {
            var isCheckedAll = $($chks.selector + ":checked").length === $chks.length;
            $chkall.prop("checked", isCheckedAll);
        });

        $(document).on("click", $btnok.selector, function (e) {
            var selectedArray = [];
            $($chks.selector + ":checked").each(function (idx, el) {
                selectedArray.push($(this).data("value"));
            });
            $txtlookup.val(selectedArray.join(";"));
            $popuplookup.removeClass("open");
        });

        $(document).on("click", $btncancel.selector, function (e) {
            $popuplookup.removeClass("open");
        });
    }
}(window.jQuery);